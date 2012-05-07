package ui 
{
	import core.ResourceManager;
	
	import flash.ui.Keyboard;
	
	import starling.display.Button;
	import starling.display.Sprite;
	import starling.events.Event;
	import starling.events.KeyboardEvent;
	import starling.events.TouchEvent;
	import starling.textures.Texture;
	
	
	public class Menu extends Sprite
	{
		private var _items   : Array;
		private var _spacing : Number;
		private var _upTexture : Texture;
		private var _downTexture : Texture;
		private var _defFunc : Function = function(idx : Number, title : String, e : TouchEvent): void { };
		
		private var _buttons : Array = new Array();	
		public  var active : Number = 0;
		
		public function Menu( upTexture : String, downTexture: String, spacing : Number, items : Array, defFunc : Function ) 
		{
			super();
			_upTexture = ResourceManager.getTexture( upTexture );
			_downTexture = ResourceManager.getTexture( downTexture );
			_items = items;
			_spacing = spacing;
			_defFunc = defFunc;
			initializeButtons();
		}
		
		private function initializeButtons(): void
		{
			var by : Number = 0;
			var idx : Number = 0;
			
			
			for each(var item : * in _items) {
				var title : String = item is String ? item : item[0];
				var btn : Button = new Button(_upTexture, title, _downTexture);
				btn.y = by;
				
				btn.addEventListener(TouchEvent.TOUCH, onClick );
				addChild(btn);
				
				_buttons.push( btn );
				by += _upTexture.height + _spacing;
				idx += 1;
			}
			
			addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
			addEventListener(Event.REMOVED_FROM_STAGE, onRemovedFromStage);
		}
		
		private function onClickOrShortcut(idx : Number, e : Event) :void {
			if ( idx < 0 ) {
				trace("button not found");
				return;
			}
			
			var title : String = '';
			var func : Function = _defFunc;
			
			if ( _items[idx] is Array ) {
				title = _items[idx][0];
				func  = _items[idx].length > 2 ? _items[idx][2] : _defFunc;
			} else {
				title = _items[idx];
				func = _defFunc;
			}
			
			setActive(idx);
			func(idx, title, e);
		}
		
		private function onClick( e : TouchEvent ): void {
			if (e.getTouch(stage).phase != "ended") return;
			var idx : Number = -1;
			for ( var i : Number = 0; i < _buttons.length; i += 1 ) {
				if ( _buttons[i] == e.currentTarget ) {
					idx = i;
					break;
				}
			}
			
			onClickOrShortcut(idx, e);
		}
		
		private function onKeyDown(e : KeyboardEvent) :void {
			var activeItem : Array = null;
			for each(var item : * in _items) {
				if (item is Array && item.length > 1 && item[1] == e.keyCode) {
					activeItem = item;
					break;
				}
			}
			
			if (activeItem == null) {
				return;
			}
			
			var idx : Number = -1;
			for ( var i : Number = 0; i < _buttons.length; i += 1 ) {
				if ( (_buttons[i] as Button).text == activeItem[0]) {
					idx = i;
					break;
				}
			}
			
			onClickOrShortcut(idx, e);
		}
		
		private function onAddedToStage(e : Event) :void {
			removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
			stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
		}
		
		private function onRemovedFromStage(e : Event ): void {
			stage.removeEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
		}
		
		public function clearActive(): void {
			active = -1;
			for ( var i : Number = 0; i < _buttons.length; i += 1 ) {
				(_buttons[i] as Button).visible = true;
				(_buttons[i] as Button).enabled = true;
				(_buttons[i] as Button).alpha = 1.0;
			}
		}
		
		public function setActive( id : Number ): void {
			active = id;
			for ( var i : Number = 0; i < _buttons.length; i += 1 ) {
				(_buttons[i] as Button).enabled = i == id;
				(_buttons[i] as Button).alpha = i == id ? 1.0 : 0.3;
			}
		}
	}

}
