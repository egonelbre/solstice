package core 
{
	import flash.utils.getQualifiedClassName;
	import flash.utils.Dictionary;
	
	public class EntityManager 
	{
		protected var _allEntities   : Array = new Array();           // simple array of Entity
		protected var _allComponents : Dictionary = new Dictionary(); // Component.Class --> Array< Component >
		
		public function EntityManager() 
		{
			
		}
		
		public function getAllEntities(): Array {
			return _allEntities;
		}
		
		public function getAllComponentsOfType( type: Class ) : Array {
			var store : Array = _allComponents[ type ] as Array;
			return store;
		}
		
		public function $$( type: Class ) : Array {
			return getAllComponentsOfType( type );
		}
		
		public function findByName(name: String): Entity {
			// TODO: this can be done in O(1)
			for (var i:Number = 0 ; i < _allEntities.length ; ++i ) {
				if (_allEntities[i].name == name) {
					return _allEntities[i];
				}
			}
			trace ('EntityManager.findByName: warning, entity ' + name + ' not found')
			return null;
		}
		
		internal function addComponent( t : Component ) : void {
			var type : Class = Object(t).constructor;
			var components : Array = _allComponents[ type ];
			
			if ( components == null ) {
				components = new Array( t );
				_allComponents[ type ] = components;
			} else {
				components.push( t );
			}
		}
		
		public function removeComponent( t : Component ) : void {
			var type: Class = Object(t).constructor;
			var components : Array = _allComponents[ type ] as Array;
			if ( components == null )
				throw new Error("REMOVE FAIL: there are no entities with a component " + getQualifiedClassName( t ));
			
			var i : Number = components.indexOf( t );
			if ( i < 0 )
				throw new Error("REMOVE FAIL: component of type " + getQualifiedClassName( t ) + " does not exist!" );
			
			(components[i] as Component).cleanup();
			components.splice(i, 1);
			if ( components.length == 0 )
				delete( _allComponents[ type ] );
		}
		
		public function addEntity( entity: Entity ) : void {
			_allEntities.push( entity );
		}
		
		public function addEntityAt(entity: Entity, idx: Number): void {
			_allEntities.splice(idx, 0, entity);
		}
		
		public function removeEntity( entity : Entity ) : void { 
			var i: Number = _allEntities.indexOf( entity );
			if ( i < 0 )
				return ;
			_allEntities.splice( i, 1 );
			entity.removeAllComponents();
		}
		
		public function removeAllEntities(): void {
			var entities : Array = _allEntities.slice();
			for each(var e : Entity in entities) {
				removeEntity( e );
			}
		}
	}

}