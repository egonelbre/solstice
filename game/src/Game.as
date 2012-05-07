package  
{
	import core.Jukebox;
	import flash.ui.Keyboard;
    import flash.utils.getDefinitionByName;
    import flash.utils.getQualifiedClassName;
	import starling.display.Quad;
	import starling.events.KeyboardEvent;
	import starling.text.BitmapFont;
	
	import starling.textures.Texture;
	import starling.display.Button;
	import starling.display.Image;
	import starling.display.Sprite;
	import starling.events.Event;
	import starling.events.TouchEvent;
	
	import starling.text.TextField;
	import starling.utils.HAlign;
	import starling.utils.VAlign;
	
	import fr.kouma.starling.utils.Stats;	
	
	import core.Scene;
	import core.Entity;
	import core.World;
	
	import core.ResourceManager;
	import core.Definitions;
	
	import ui.Menu;
	
	import utils.Serializer;
	
	import levels.LevelOne;
	
	public class Game extends Sprite
	{
		private var mMainMenu: Sprite;
		private var menu: Menu;
		private var worldIds : Array;
		private var mCurrentScene: Scene;
		private var stats : Stats;
		private var loading : Image;
		
		private var errors : TextField;
		private var errorsBG : Quad;
		
		//private var fsAssets : FileSystemAssets;
		private var fsAssets: Object;
		
		public function Game() 
		{
			Includer.init(); // force including components and systems
			//fsAssets = new FileSystemAssets(startReloadingContent, endReloadingContent, onAssetsReloadingError);
			//fsAssets.reload();
			//ResourceManager.initialize([fsAssets, StaticAssets]);
			ResourceManager.initialize([XMLAssets, AutoAssets, StaticAssets]);
			
			stats = new Stats();
			stats.x = 5;
			stats.y = 550;
			addChild(stats);
			stats.visible = false;
			
			mMainMenu = new Sprite();
			addChild( mMainMenu );
			
			loading = new Image( ResourceManager.getTexture("textures/ui/loading.png") );
			addChild(loading);
			
			var bg : Image = new Image( ResourceManager.getTexture("textures/ui/mainmenu_background.png") );
			mMainMenu.addChild(bg);
			
			if( fsAssets != null ){
				var btn : Button = new Button( ResourceManager.getTexture("textures/ui/buttons/reload.png"));
				btn.addEventListener( Event.TRIGGERED, function(e : Event ): void { fsAssets.reload(); });
				mMainMenu.addChild(btn);
			}
			
			addEventListener( Scene.CLOSING, onSceneClosing );
			addEventListener( Event.ADDED_TO_STAGE, onAddedToStage );
			addEventListener( Event.ENTER_FRAME, onEnterFrame );
			
			var errWidth : Number = 500;
			var errHeight : Number = Constants.GameHeight - 100;
			
			errors = new TextField(errWidth, errHeight, '');
			errors.fontSize = 15;
			errors.x = 50;
			errors.y = 50;
			errors.vAlign = VAlign.TOP;
			errors.hAlign = HAlign.LEFT;
			errorsBG = new Quad(errWidth + 20, errHeight + 20, 0xffeeee);
			errorsBG.alpha = 0.2;
			errorsBG.x = errors.x - 10;
			errorsBG.y = errors.y - 10;
			addChild(errorsBG);
			errorsBG.visible = false;
			addChild(errors);
		}
		
		public function startReloadingContent(): void
		{
			Jukebox.stop();
			if( loading != null ){
				loading.visible = true;
				errors.text = '';
				errorsBG.visible = false;
				setChildIndex( loading, numChildren );
			}
		}
		
		public function endReloadingContent(): void
		{
			if( menu != null )
				mMainMenu.removeChild( menu );
			Definitions.reload('definitions.xml');
			menu = createLevelMenu();
			mMainMenu.addChild( menu );
			
			loading.visible = false;
			
			Jukebox.play('moving');
		}
		
		public function onAssetsReloadingError(msg : String): void
		{
			errorsBG.visible = true;
			errors.text += msg + '\n';
		}
		
		private function onEnterFrame( e : Event ): void {
			setChildIndex(stats, numChildren);
			KeyboardControls.update();
		}
		
		private function onAddedToStage( e : Event ): void {
			removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
			KeyboardControls.initialize(stage);
			stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown );
			if( fsAssets == null )
				endReloadingContent();
		}
		
		private function onKeyDown( e : KeyboardEvent ): void {
			if ( e.keyCode == Keyboard.F ) {
				stats.visible = !stats.visible;
			}
		}
		
		private function createLevelMenu(): Menu {
			var worldNames : Array = new Array();
			var worldIds : Array = new Array();
			
			for ( var worldID:* in Definitions.getWorlds()) {
				trace ('Adding world with id ' + worldID + ' to menu')
				worldIds.push( worldID );
				worldNames.push( Definitions.getWorlds()[worldID].@title );
			}
			
			var menu : Menu = new Menu("textures/ui/buttons/big.png", "textures/ui/buttons/big.png", 10, worldNames, 
				function(idx: Number, title: String, e: TouchEvent): void {
            		showScene(worldIds[idx]);
					menu.clearActive();
				}
			);
			
			menu.x = 650;
			menu.y = 300;
			
			return menu;
		}
        
        private function onSceneClosing(event:Event):void
        {
            mCurrentScene.removeFromParent(true);
            mCurrentScene = null;
            mMainMenu.visible = true;
        }
        
        private function showScene(id:String):void
        {
            if (mCurrentScene) return;
			var xml: XML = Definitions.getWorlds()[id];
			var world: World = new LevelOne();
			world.unserialize(xml);
            mCurrentScene = world;
			addChild(mCurrentScene);
			mMainMenu.visible = false;
        }
	}

}