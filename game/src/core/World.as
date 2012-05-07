package core
{
	import starling.events.Event;
	import utils.Serializer;
	import editor.Editor;
	
	public class World extends Scene
	{
		public var _sys : Systems;
		
		public var _hud  : SceneObject;
		public var _editor : Editor;
		
		protected var id: String;
		protected var title: String;
		
		public function get sys() : Systems { return _sys; };
		public function get hud() : SceneObject { return _hud; };
		
		public function World()
		{
			_sys = new Systems();
			_hud = new SceneObject();
			_editor = new Editor(this);
			super();
		}
		
		override public function setupScene(e: Event): void
		{
			addChild( sys.root );
			addChild( _hud );
			addChild( _editor );
			// should be sys.unserialize( data );
			
			addElements();
			super.setupScene(e);
		}
		
		dynamic public function addElements(): void
		{
			for each (var en:Entity in _sys.em.getAllEntities()) {
				sys.root.addChild(en);
			}
		}
		
		
		override public function update(e: Event): void
		{
			sys.update();
		}
		
		public function serialize(): XML
		{
			var data : XML =  sys.serialize();
			data.setName("world");
			data.@id = id;
			data.@title = title;
			return data;
		}
		
		public function unserialize( data : XML ): void
		{
			sys.unserialize( data );
			// if we have the editor, then make them editable
			if (_editor != null) {
				sys.addEditor(_editor);
			}
			id = data.@id;
			title = data.@title;
		}
		
		override public function dispose(): void
		{
			_sys.cleanup();
			super.dispose();
		}
	}
}