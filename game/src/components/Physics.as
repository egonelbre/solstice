package components 
{
	import Box2D.Collision.b2Pair;
	import Box2D.Dynamics.b2ContactListener;
	import Box2D.Collision.Shapes.b2CircleShape;
	import Box2D.Collision.Shapes.b2PolygonShape;
	import Box2D.Collision.Shapes.b2Shape;
	import Box2D.Common.Math.b2Vec2;
	import Box2D.Dynamics.b2Body;
	import Box2D.Dynamics.b2BodyDef;
	import Box2D.Dynamics.b2Fixture;
	import Box2D.Dynamics.b2FixtureDef;
	import core.Component;
	import flash.events.DataEvent;
	import systems.Box2DWorld;
	import utils.Serializer;
	
	import utils.Fixture;
	
	public class Physics extends Component
	{
		protected var _world:Box2DWorld = null;
		
		[Serialize]
		public var fixedRotation: Boolean = false;
		[Serialize]
		public var isDynamic: Boolean = false;
		[Serialize]
		public var isKinematic: Boolean = false;
		[Serialize]
		public var anchor: Array = [0, 0];
		
		public var fixtures: Array = [];
		public var sensors : Object = new Object();
		
		public var body: b2Body;
		
		public function Physics()
		{
			super();
		}
		
		public override function setup(): void {			
			if ( _world == null ) {
				_world = owner.sys.$(Box2DWorld) as Box2DWorld;
			}
			
			// called after setting owner property
			var bodyDef : b2BodyDef = new b2BodyDef();
			bodyDef.userData = this;
			bodyDef.fixedRotation = fixedRotation;
			
			if( isKinematic )
				bodyDef.type = b2Body.b2_kinematicBody;
			else if ( isDynamic )
				bodyDef.type = b2Body.b2_dynamicBody;
			else
				bodyDef.type = b2Body.b2_staticBody;
			
			body = _world.world.CreateBody(bodyDef);
			
			for each ( var f : Fixture in fixtures ) {
				var fixDef : b2FixtureDef = new b2FixtureDef();
				fixDef.density = f.density;
				fixDef.friction = f.friction;
				fixDef.restitution = f.restitution;
				fixDef.isSensor = f.isSensor;
				fixDef.userData = [this, f.sensorId];
				
				if ( owner.hasComponent(Machine) && !f.isSensor) {
					fixDef.filter.categoryBits = 2;
					fixDef.filter.maskBits = 3;
				}
				
				if ( f.sensorId == "acorn" ) {
					fixDef.filter.maskBits = 3;
					fixDef.filter.categoryBits = 1;
				}
				
				if ( f.isSensor ) {
					this.sensors[ f.sensorId ] = 0;
				}
				
				var shape : b2Shape;
				if ( f.type == "CIRCLE" ) {
					var circle : b2CircleShape = new b2CircleShape( f.circleRadius * Constants.SimulationScale );
					circle.SetLocalPosition( new b2Vec2( f.circleX * Constants.SimulationScale, f.circleY * Constants.SimulationScale ));
					fixDef.shape = circle;
					body.CreateFixture(fixDef);
				} else {
					for each (var poly : Array in f.polygons ){
						var poly_shape : b2PolygonShape = new b2PolygonShape();
						var polygon : Array = [];
						for (var i : Number = 0; i < poly.length; i += 2) {
							polygon.push( 
								new b2Vec2( 
								 	poly[i] * Constants.SimulationScale, 
									poly[i + 1] * Constants.SimulationScale ) );
						}
						poly_shape.SetAsArray( polygon, polygon.length );
						fixDef.shape = poly_shape;
						body.CreateFixture( fixDef );
					}
				}	
			}
			owner.pivotX = anchor[0];
			owner.pivotY = anchor[1];
			setPosition(b2Vec2.Make(owner.x, owner.y));
			setAngle(owner.rotation);
		}
		
		public override function cleanup(): void {
			_world.world.DestroyBody( body );
		}
		
		public function sensorActive( id : String ): Boolean {
			if ( sensors.hasOwnProperty(id) ) {
				return sensors[id] > 0;
			}
			return false;
		}
		
		public function getPosition():b2Vec2 {
			var pos:b2Vec2 = body.GetPosition().Copy();
			pos.x /= Constants.SimulationScale;
			pos.y /= Constants.SimulationScale;
			return pos;
		}
		
		public function setPosition(pos:b2Vec2):void {
			if ( _world == null ) return;
			pos.x *= Constants.SimulationScale;
			pos.y *= Constants.SimulationScale;
			body.SetPosition(pos);
			body.SetAwake(true);
		}
		
		public function getAngle():Number {
			if ( body == null ) return 0;
			return body.GetAngle();
		}
		
		public function setAngle(angle:Number):void {
			body.SetAngle(angle);
			body.SetAwake(true);
		}
		
		public function getWidth():Number {
			return this.owner.width;
		}
		
		public function getHeight():Number {
			return this.owner.height;
		}
		
		public override function toString():String {
			return "x: " + getPosition().x + 
				   " y: " + getPosition().y + 
				   " angle: " + getAngle() + 
				   " width: " + getWidth() + 
				   " height: " + getHeight();
		}
		
		override public function serialize(): XML {
			var content : XML = Serializer.serializeObject(this, "component");
			if ( content == null ) return null;
			if( this.name != "" )
				content.@name = this.name;
			
			for each(var f : Fixture in fixtures ) {
				var data : XML = f.serialize();
				content.appendChild(data);
			}
			return content;
		}
		
		override public function unserialize(data : XML): void {
			Serializer.unserializeToObject(data, this);
			for each( var e : XML in data.elements("fixture") ) {
				var f : Fixture = new Fixture();
				f.unserialize( e );
				fixtures.push( f );
			}
		}
	}

}