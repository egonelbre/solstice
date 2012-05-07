package core 
{
	import flash.utils.ByteArray;
	import flash.utils.getQualifiedClassName;
	import utils.Serializer;
	
	public class Component
	{
		internal var _owner : Entity;		
		public var name: String = "";
		public var template: String = "";
		
		public function get owner() : Entity { return _owner; }
		
		public function Component() {
			
		}
		
		public function setup(): void {
			// called after setting owner property
		}
		
		public function cleanup(): void {
			// called before removing from owner
		}
		
		public function toString(): String {
			return getQualifiedClassName( this );
		}
		
		public dynamic function serialize(): XML {
			var content : XML = Serializer.serializeObject(this, "component");
			if ( content == null ) return null;
			
			if( this.name != "" )
				content.@name = this.name;
			
			return content;
		}
		
		public dynamic function unserialize(data : XML): void {
			Serializer.unserializeToObject(data, this);
		}
	}

}