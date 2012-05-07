package utils 
{
	import flash.utils.describeType;
	import flash.utils.getDefinitionByName;
	
	import core.Component;
	import core.Entity;
	import core.EntityManager;
	import core.System;
	import core.Systems;

	public class Serializer 
	{
		public var xml: XML;
		
		public function Serializer() {
			xml = <obj />;
		}
		
		public function traceObj( obj : Object ): void {
			var desc : XML = describeType( obj );
			var prop : XML;
			var propValue : Object;
			
			for each(prop in desc.elements("variable")) {
				propValue = obj[ prop.@name ];
				if ( propValue != null ) {
					trace( prop.@name, propValue.toString());
				}
			}
		}
		
		public function addNumber( propName: String, propVal: Number) : XML {
			var xmlProp: XML = <new />;
			xmlProp.setName( propName );
			xmlProp.appendChild( propVal );
			xml.appendChild( xmlProp );
			return xmlProp;
		}
		
		public function addBoolean( propName: String, propVal: Boolean) : XML {
			var xmlProp: XML = <new />;
			xmlProp.setName( propName );
			xmlProp.appendChild( propVal );
			xml.appendChild( xmlProp );
			return xmlProp;
		}
		
		public function addString( propName: String, propVal: String) : XML {
			var xmlProp: XML = <new />;
			xmlProp.setName( propName );
			xmlProp.appendChild( propVal );
			xml.appendChild( xmlProp );
			return xmlProp;
		}
		
		static public function serializeObject( source : Object, tag : String = "Object" ) : XML {
			var writer : Serializer = new Serializer();
			var desc : XML = describeType( source );
			var prop : XML;
			var propType : String;
			var propValue : Object;
			var hasSerialize : Boolean;
			var className: String = desc.@name;
			
			if ( desc.metadata.( @name == "NoSerialize" )[0] != undefined )
				return null;
			
			className = className.replace("::", ".");
			writer.xml.setName(tag);
			writer.xml.@type = className;
			
			for each(prop in desc.elements("variable")) {
				hasSerialize = ( prop.metadata.( @name == "Serialize" )[0] != undefined );
				if (!hasSerialize) continue;
				
				propValue = source[ prop.@name ];
				if ( propValue != null ) {
					writer.addString( prop.@name, propValue.toString());
				}
			}
			
			return writer.xml;
		}
		
		static public function unserializeAttributes( data : XML, dest : Object ) : void {
			var prop : XML;
			
			for each ( prop in data.attributes() ) {
				if ( !dest.hasOwnProperty( prop.name() ) ) {
					if (prop.name() != "type" && prop.name() != 'id') {
						dest[prop.name()] = prop;
					}
				} else { 
					trace("doesn't have property: ", prop.name() );
				}
			}
		}
		
		static public function unserializeElements( data : XML, dest : Object ) : void {
			var prop : XML;
			
			for each ( prop in data.children() ) {
				if ( prop.name() == "properties" ) {
					unserializeElements( prop, dest );
				}
				if ( !dest.hasOwnProperty( prop.name() ) ) {
					trace("doesn't have property: ", prop.name());
					continue;
				}
				if ( dest[ prop.name()] is Array ) {
					var a : Array = (prop.toString()).split(",");
					for (var i : int; i < a.length; i++ ) {
						a[i] = parseFloat( a[i] );
						dest[ prop.name() ] = a;						
					}
				} else if ( dest[prop.name()] is Boolean ) {
					dest[prop.name()] = prop == "true";
				} else {
					dest[ prop.name() ] = prop;
				}
			}
		}
		
		static public function unserializeToObject( data : XML, dest : Object ) : void
		{
			unserializeAttributes(data, dest);
			unserializeElements(data, dest);
		}
		
		static public function createComponent( data : XML ) : Component {
			var type: String = data.@type;
			var cls : Class = getDefinitionByName( type ) as Class;
			var obj : Component = new cls();
			obj.unserialize( data );
			return obj;
		}
		
		static public function createEntity( data : XML, sys : Systems ) : Entity {
			var ent : Entity = new Entity(data.@name, sys);
			ent.unserialize( data );
			return ent;
		}
		
		static public function createSystem( data : XML, sys : Systems ) : System {
			var type: String = data.@type;
			var cls : Class = getDefinitionByName( type ) as Class;
			var system : System = new cls(sys);
			system.unserialize( data );
			return system;
		}
	}
}