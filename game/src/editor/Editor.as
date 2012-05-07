package editor 
{
	import Box2D.Common.Math.b2Vec2;
	import Box2D.Dynamics.Joints.b2RevoluteJointDef;
	import Box2D.Dynamics.b2Fixture;
	
	import components.Physics;
	
	import core.*;
	import core.Definitions;
	
	import flash.display.DisplayObject;
	import flash.geom.Point;
	import flash.net.SharedObjectFlushStatus;
	import flash.ui.Keyboard;
	
	import starling.display.Button;
	import starling.display.Sprite;
	import starling.events.Event;
	import starling.events.KeyboardEvent;
	import starling.events.Touch;
	import starling.events.TouchEvent;
	import starling.textures.Texture;
	
	import systems.Box2DWorld;
	import systems.Camera;
	
	import ui.Menu;
	
	import utils.Serializer;
		
	// TODO: teha GUI struktuur mõistlikumaks
	public class Editor extends Sprite
	{
		protected var _entity: Entity;
		protected var _world: World;
		
		protected var _buttonTex: Texture;0
		
		protected var _menu : Menu;
		protected var _entities : Menu;
		protected var entityFunc: Function = null;
		protected var _state : String = '';
		
		// entity buttons
		protected var _entityButtons: Array;
		protected var _scrollUp: Button;
		protected var _scrollDown: Button;
		
		public function Editor(world: World) 
		{
			_world = world;
			_buttonTex = ResourceManager.getTexture("textures/ui/buttons/big.png");
			visible = false;
			
			/*_menu = new Menu("textures/button_normal.png", "textures/button_normal_down.png", 0,
				["Move", "Rotate", "Scale", "Remove entity", "Show/Hide panel"], function(idx: Number, title: String, event: TouchEvent):void {
					trace("MENU PRESS: ", idx, ": ", title );
				}); */
				
			_menu = new Menu("textures/ui/buttons/normal.png", "textures/ui/buttons/normal_down.png", 0,
				[ ["Move", Keyboard.NUMBER_1,
					function(idx: Number, title: String, e: Event): void {
						entityFunc = moveEntity;
						trace("pressed move");
				  }],
				  ["Rotate", Keyboard.NUMBER_2,
				  	function(idx: Number, title: String, e: Event): void {
						entityFunc = rotateEntity
				  }],
				  /*["Scale", 
				  	function(idx: Number, title: String, e: TouchEvent): void {
						entityFunc = scaleEntity
				  }],*/
				  ["Remove entity", Keyboard.NUMBER_3, 
				  	function(idx: Number, title: String, e: Event): void {
						entityFunc = entityRemove;
				  }],
				  ["To front", Keyboard.NUMBER_4,
				  	function(idx: Number, title: String, e: Event): void {
						entityFunc = entityToFront;
				  }],
				  ["To back", Keyboard.NUMBER_5,
				  	function(idx: Number, title: String, e: Event): void {
						entityFunc = entityToBack;
				  }],
				  ["Show/Hide panel", Keyboard.NUMBER_6,
				  	function(idx: Number, title: String, e: Event): void {
					  	_entities.visible = !_entities.visible;
						_scrollDown.visible = _entities.visible;
						_scrollUp.visible = _entities.visible;
						_menu.clearActive();
				  }],
				  /*["Save level", Keyboard.NUMBER_7,
					function(idx: Number, title: String, e: Event): void {
						var xml:XML = _world.serialize();
						ResourceManager.saveAsXML('levels/world1.xml', xml);
						_menu.clearActive();
				  }],*/
			      ["Move Camera", Keyboard.NUMBER_7,
					function(idx: Number, title: String, e: Event): void {
						var c : Camera = _world.sys.$(Camera) as Camera;
						c.manualCamera = !c.manualCamera; 
						_menu.clearActive();
				  	}
				  ]]
				, function(idx: Number, title: String, event: Event):void {
					trace("btn not defined: ", idx, ": ", title );
				});
				
			_menu.x = 10;
			_menu.y = 10;
			addChild( _menu );
			addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
			addEventListener(Event.REMOVED_FROM_STAGE, onRemovedFromStage);
		}
		
		public function onAddedToStage( e : Event ): void {
			removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
			_world.sys.root.addEventListener(TouchEvent.TOUCH, onTouchScene);
			stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
			createEntityPanel();
		}
		
		public function onRemovedFromStage( e : Event ): void {
			stage.removeEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
		}
		
		public function onKeyDown(e : KeyboardEvent): void
		{
			if ( e.keyCode == Keyboard.E ) {
				visible = !visible;
			}
		}

		protected function createEntityPanel(): void {
			// now create entity buttons
			_entityButtons = new Array();
			var dict: Object = Definitions.getTemplates();
			var entityIDs: Array = new Array();
			
			for (var key:* in dict) {
				var xml: XML = dict[key];
				entityIDs.push(xml.@id.toString());
			}
			
			entityIDs.sort();
			
			_entities = new Menu("textures/ui/buttons/normal.png", "textures/ui/buttons/normal_down.png", 0, 
				entityIDs, 
				function(idx: Number, title: String, event: TouchEvent):void {
					addEntityToWorld(title);
					_entities.clearActive();
				});
			_entities.x = Constants.GameWidth - _entities.width - 10;
			_entities.y = 10;
			_entities.visible = false;
			addChild(_entities);
			
			var up : Texture = ResourceManager.getTexture("textures/ui/buttons/up.png");
			var down : Texture = ResourceManager.getTexture("textures/ui/buttons/down.png");
			// create scrolling buttons
			
			_scrollUp = new Button(up);
			_scrollDown = new Button(down);
			
			_scrollUp.x = _entities.x - _scrollUp.width;
			_scrollDown.x = _entities.x - _scrollDown.width;
			
			_scrollUp.y = 10;
			_scrollDown.y =  _scrollUp.y + _scrollUp.height;
			
			_scrollUp.visible = false;
			_scrollDown.visible = false;
			
			_scrollUp.addEventListener(TouchEvent.TOUCH, onScrollUp);
			_scrollDown.addEventListener(TouchEvent.TOUCH, onScrollDown);
			
			addChild(_scrollUp);
			addChild(_scrollDown);
		}
		
		protected function addEntityToWorld(title: String): void {
			var en:Entity = Serializer.createEntity(Definitions.getTemplates()[title], _world.sys);
			en.name = 'ed_' + title + '_' + (Math.random() * 100000).toString(); // replace this with uuid
			_world.sys.root.addChild(en)
			
			var pos : Point =_world.sys.root.globalToLocal( new Point(200, 200) );
			
			en.x = pos.x;
			en.y = pos.y;
			en.template = title;
			if( en.hasComponent(Physics) )
				(en.$(Physics) as Physics).setPosition(b2Vec2.Make(en.x, en.y));
		}
		
		protected function onScrollUp(event: TouchEvent): void {
			if (event.getTouch(stage).phase == "ended") {
				for each (var b:Button in _entityButtons) {
					b.y -= Constants.EntityPanelScrollAmount;
				}
				_entities.y -= Constants.EntityPanelScrollAmount;
			}
		}
		
		protected function onScrollDown(event: TouchEvent): void {
			if (event.getTouch(stage).phase == "ended") {
				for each (var b:Button in _entityButtons) {
					b.y += Constants.EntityPanelScrollAmount;
				}
				
				_entities.y += Constants.EntityPanelScrollAmount;
			}
		}

		protected function findEntity(pos: Point ): Entity {
			var physWorld : Box2DWorld = _world.sys.$(Box2DWorld) as systems.Box2DWorld;
			var p : b2Vec2 = new b2Vec2(pos.x, pos.y);
			p.Multiply(Constants.SimulationScale)
			var en : Entity = null ;
			physWorld.world.QueryPoint(function(fix: b2Fixture): void {
				var phys : Physics = fix.GetBody().GetUserData() as Physics;
				var nen : Entity = phys.owner;
				if ( en == null )
					en = nen;
				if( en.parent.getChildIndex(en) < nen.parent.getChildIndex(nen) )
					en = nen;
			}, p);
			
			
			if ( en != null ) return en;
			
			for each( var nen: Entity in _world.sys.em.getAllEntities() ) {
				if ( (pos.x < nen.x) || 
				     (pos.y < nen.y) ||
					 (pos.x > nen.x + nen.width) || 
					 (pos.y > nen.y + nen.height))
					continue;
				if ( en == null )
					en = nen;
				if( en.parent.getChildIndex(en) < nen.parent.getChildIndex(nen) )
					en = nen;
			}
			return en;
		}
		
		
		protected function setEditing( value : Boolean ) : void {
			var world : Box2DWorld = _world.sys.$( Box2DWorld ) as Box2DWorld;
			world.editing = value;
		}
		
		protected function onTouchScene(event : TouchEvent ): void {
			var touch : Touch = event.getTouch(stage);
			if (touch.phase == "began") {
				var pos:Point = touch.getLocation(_world.sys.root);
				_entity = findEntity( pos );
				if ( _entity != null )
					setEditing(true);
			} else if (touch.phase == "moved") {
				if ( (entityFunc == null) || ( _entity == null ) )
					return;
				entityFunc(event)
			} else if (touch.phase == "ended") {
				setEditing(false);
				if ( (entityFunc == null) || ( _entity == null ) )
					return;
				entityFunc(event)
			}
		}
		
		protected function createButton(name: String, lastButton: Button = null): Button {
			var button: Button = new Button(_buttonTex, name);
			button.x = 200;
			if (lastButton != null) {
				button.y = lastButton.y + _buttonTex.height * 1.2;
			}
			return button;
		}		
		
		protected function onShowHideButton(event: TouchEvent): void {
			if (event.getTouch(stage).phase == "ended") {
				for each(var b:Button in _entityButtons) {
					b.visible = !b.visible;
				}
				_scrollUp.visible = !_scrollUp.visible;
				_scrollDown.visible = !_scrollDown.visible;
			}
		}
		
		protected function moveEntity(event: TouchEvent): void {
			var touch: Touch = event.getTouch(stage);
			var pos:Point = touch.getLocation(_world.sys.root);
			var pc:Physics = _entity.$(Physics) as Physics;
			if ( pc == null ) return;
			pc.setPosition(b2Vec2.Make(pos.x, pos.y));
		}
		
		protected function rotateEntity(event: TouchEvent): void {
			var touch: Touch = event.getTouch(stage);
			var pos:Point = touch.getLocation(_world.sys.root);
			var pc:Physics = _entity.$(Physics) as Physics;
			if ( pc == null ) return;
			trace( pos );
			var angle:Number = Math.atan2(pos.x - pc.getPosition().x,
										  pos.y - pc.getPosition().y);
			pc.setAngle(Math.PI/2 - angle);
		}
		
		protected function entityRemove(event : TouchEvent ): void {
			if ( event.getTouch(stage).phase !== "ended" ) return;
			this._world.sys.em.removeEntity(_entity);
			_entity.parent.removeChild(_entity, true);
		}
		
		protected function entityToBack(event: TouchEvent): void {
			if ( event.getTouch(stage).phase !== "ended" ) return;
			var idx : Number = _entity.parent.getChildIndex( _entity );
			if ( idx > 1 )
				_entity.parent.setChildIndex( _entity, idx - 1 );
		}
		
		protected function entityToFront(event: TouchEvent): void {
			if ( event.getTouch(stage).phase !== "ended" ) return;
			var idx : Number = _entity.parent.getChildIndex( _entity );
			if ( idx < _entity.parent.numChildren - 1 )
				_entity.parent.setChildIndex( _entity, idx + 1 );
		}
		
		protected function scaleEntity(event: TouchEvent): void {
			var touch: Touch = event.getTouch(stage);
			var pos:Point = touch.getLocation(stage)
			var pc:Physics = _entity.$(Physics) as Physics;
			if ( pc == null ) return;
			pc.setAngle(0);
		}
	}
}