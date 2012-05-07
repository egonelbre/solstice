package core 
{
	import editor.Editor;
	import flash.utils.Dictionary;
	import utils.Serializer;
	
	public class Systems 
	{
		protected var _root : SceneObject = new SceneObject();
		
		protected var _systems : Array = new Array();
		protected var _entityManager : EntityManager = new EntityManager();
		protected var _clock : Clock = new Clock();
		
		public function get em() : EntityManager { return _entityManager };
		public function get clock() : Clock { return _clock };
		
		public function get root(): SceneObject { return _root };
		
		public function Systems() {
			_clock.Run();
		}
		
		public function addSystem( sys : System ) : void {
			_systems.push( sys );
		}
		
		public function removeSystem( sys : System ) : void {
			var i : Number = _systems.indexOf( sys );
			if( i >= 0 )
				_systems.splice(i, 1);
			sys.cleanup();
		}
		
		public function getSystem( type : Class ) : System {
			for each ( var sys : System in _systems ) {
				if ( sys is type ) {
					return sys;
				}
			}
			throw new Error("No such system available!");
			return null;
		}
		
		public function $( type : Class ): System {
			return getSystem( type );
		}
		
		public function update(): void {
			_clock.BeginFrame();
			for each ( var sys : System in _systems ) {
				sys.processOneGameTick( _clock );
			}
			_clock.AdvanceToEnd();
		}
		
		public function addEditor(ed:Editor): void {
			//
		}
		
		public function serialize(): XML {
			var writer : Serializer = new Serializer();
			var entities : Array = em.getAllEntities();
			
			for each ( var sys : System in _systems ) {
				var sysdata : XML = sys.serialize();
				writer.xml.appendChild( sysdata );
			}
			
			for each ( var entity : Entity in entities ) {
				var data : XML = entity.serialize();
				writer.xml.appendChild( data );
			}
			
			return writer.xml;
		}
		
		public function unserialize(data : XML): void {
			for each ( var sysd : XML in data.elements("system") ) {
				Serializer.createSystem(sysd, this);
			}
			
			for each ( var entd : XML in data.elements("entity") ) {
				Serializer.createEntity(entd, this);
			}
		}
		
		public function removeAllSystems(): void {
			var systems : Array =  _systems.slice();
			for each( var sys : System in systems )
				removeSystem(sys);
		}
		
		public function cleanup(): void {
			em.removeAllEntities();
			removeAllSystems();
		}
	}

}