package core 
{
	//import air.update.logging.Level;
	import flash.events.Event;
	import flash.utils.Dictionary;
	import flash.utils.getQualifiedClassName;
	import utils.Serializer;
	import starling.display.DisplayObject;
	
	public class Entity extends SceneObject
	{
		protected var _sys : Systems;
		public function get sys() : Systems { return _sys; }
		
		protected var _components : Dictionary = new Dictionary; // Component.Class --> Vector< Component >
		protected var _id : String; // should be unique on network
		
		// template to be used for initiation
		public var template : String = '';
		// set this to true if this shouldn't be serialized
		public var isDynamic: Boolean = false;
		
		public function Entity( name: String, sys : Systems ) {
			_sys = sys;
			this.name = name;			
			sys.em.addEntity( this );
		}
		
		public function compose( t : Component ) : Entity {
			t._owner = this;
			sys.em.addComponent( t );
			addComponent( t );
			t.setup();
			return this;
		}
		
		private function addComponent( t: Component ) : void {
			var type : Class = Object(t).constructor;
			var components : Array = _components[ type ] as Array;
			
			if ( components == null ) {
				components = new Array(t);
				_components[ type ] = components;
			} else {
				components.push( t );
			}
		}
		
		public function removeComponent( t : Component ): void {
			if ( t == null ) return;
			
			var type : Class = Object(t).constructor;
			var components : Array = _components[ type ];
			
			var i : Number = components.indexOf( t );
			if ( i < 0 )
				throw new Error("REMOVE FAIL: component of type " + getQualifiedClassName( t ) + " does not exist for " + this.name );
			
			components.splice(i, 1);
			if ( components.length == 0 )
				delete( _components[ type ] );
			
			sys.em.removeComponent( t );
			
			t.cleanup();
			t._owner = null;
		}
		
		public function removeAllComponents(): void {
			var types : Array = [];
			for (var type:* in _components)
				types.push(type);
			for (var i : Number = 0 ; i < types.length; i += 1) {
				var ca : Array = _components[ types[i] ];
				if (ca == null) continue;
				delete _components[types[i]];
				
				for ( var k : Number = ca.length - 1 ; k >= 0; k -= 1 ) {
					sys.em.removeComponent( ca[k] );
					Component(ca[k]).cleanup();
					Component(ca[k])._owner = null;
				}
			}
		}
		
		public function getComponent( type : Class ) : Component {
			var components : Array = _components[ type ] as Array;
			if ( (components == null) || (components.length == 0) ){
				throw new Error("No component of type " + getQualifiedClassName( type ) + " for " + this.name );
			}
			if ( components.length > 1  ){
				throw new Error("More than 1 component of type " + getQualifiedClassName( type ) + " for " + this.name );
			}
			return components[0];
		}
		
		public function $( type : Class ) : Component {
			var components : Array = _components[ type ] as Array;
			if ( (components == null) || (components.length == 0) ) 
				return null;
			return components[0];
		}
		
		public function hasComponent( type : Class ) : Boolean {
			var components : Array = _components[ type ] as Array;
			return (components != null) && (components.length > 0);
		}
		
		public function getAllComponentsOfType( type : Class ) : Array {
			var components : Array = _components[ type ] as Array;
			if ( (components == null) || (components.length == 0) ) 
				throw new Error("No component of type " + getQualifiedClassName( type ) + " for " + this.name );
			return components;
		}
		
		public function getAllComponents() : Array {
			var result : Array = new Array();
			var arr : Array;
			for each( arr in _components ) {
				result = result.concat( arr );
			}
			return result;
		}
		
		public function $$( type : Class) : Array {
			return getAllComponentsOfType( type );
		}
		
		override public function serialize() : XML {
			var writer : Serializer = new Serializer();
			writer.xml.setName("entity");
			if( name != "" )
				writer.xml.@name = name;
			if( template != "" )
				writer.xml.@template = template;
			
			var props : XML = super.serialize();
			props.setName("properties");
			writer.xml.appendChild( props );
			
			var child : DisplayObject;
			for ( var i : int = 0 ; i < numChildren; i++ ) {
				child = getChildAt(i);
				if ( child is Entity ){
					var childData: XML = (child as Entity).serialize();
					writer.xml.appendChild( childData );
				}
			}
			
			if( template == "" ){			
				var components : Array = getAllComponents();
				for ( i = 0; i < components.length; i++ ) {
					var component: Component  = components[i] as Component;
					var componentData : XML = component.serialize();
					
					if( componentData != null )
						writer.xml.appendChild( componentData );
				}
			}
			
			return writer.xml;
		}
		
		override public function unserialize( data : XML ) : void {
			var props : XMLList = data.elements("properties");
			var prop : XML;
			
			//TODO: fix order of unserialization
			// correct order is
			// unserialize template properties, recursively highest first
			// unserialize data properties
			// unserialize template components 
			// unserialize data components
			
			Serializer.unserializeAttributes( data, this );
			for each( prop in props ) {
				Serializer.unserializeToObject(prop, this);
			}
			
			if( data.attribute("template") != undefined ){
				template = data.@template;
				
				if( template != "" ){
					var templateDef : XML = Definitions.getTemplates()[template];
					if ( templateDef == null ) {
						trace("UNKNOWN TEMPLATE: ", template );
					} else {
						unserialize( templateDef );
					}
				}
			}
			
			var components : XMLList = data.elements("component");
			var comp : XML;
			for each( comp in components ) {
				var component: Component = Serializer.createComponent(comp);
				compose( component );
			}
		}
	}

}