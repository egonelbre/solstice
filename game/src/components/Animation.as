package components 
{
	import flash.utils.Dictionary;
	import flash.media.Sound;
	
	import core.ResourceManager;
	import core.Component;
	
	import starling.core.Starling;
	import starling.display.Sprite;
	import starling.display.MovieClip;
	import starling.textures.Texture;	
	import starling.textures.TextureAtlas;
	
	public class Animation extends Component
	{
		private var _atlas : TextureAtlas;
		private var _movies : Dictionary = new Dictionary();
		private var _root : Sprite = new Sprite();
		private var _current : MovieClip;
		private var mStepSound : Sound;
		
		[Serialize]
		public var defaultAnimation : String = '';
		[Serialize]
		public var spritesheet : String;
		[Serialize]
		public var atlas : String;
		
		public function Animation() 
		{
			super();
		}
		
		public function init(atlas: String, spritesheet : String) : Component
		{
			atlas = atlas;
			spritesheet = spritesheet;
			return this;
		}
		
		private function attachSound( id : String, mMovie : MovieClip ): void {
			var sounds : Array = owner.$$(AnimationSound);
			for each (var a : AnimationSound in sounds) {
				if (a.animation == id) {
					mStepSound = ResourceManager.getSound(a.sound);
					for (var j : Number = 0; j < a.frames.length; j++)
						mMovie.setFrameSound(parseInt(a.frames[j]), mStepSound);
				}
			}
		}
		
		public function playOnce( id : String, flip : Boolean = false, fps : Number = 24 ) : void {
			play(id, flip, fps);
			_current.loop = false;
			_current.currentFrame = 0;
			_current.play();
		}
		
		public function play( id : String, flip : Boolean = false, fps : Number = 24 ) : void
		{
			if ( _atlas == null )
				trace( "ATLAS NOT DEFINED" );
			var mMovie : MovieClip;
			if ( _movies[id] == undefined ) {
				var frames : Vector.<starling.textures.Texture> = _atlas.getTextures(id);
				if (frames.length == 0) {
					trace( "ANIMATION WITH ID ", id, " NOT FOUND!!!" );
					return;
				}
				mMovie = new MovieClip( frames, fps );
				attachSound( id, mMovie );
				Starling.juggler.add( mMovie );
				_root.addChild(mMovie);
				_movies[ id ] = mMovie;
			}
			mMovie = _movies[ id ] as MovieClip;
			if ( mMovie.fps == 0 ){
				mMovie.pause();
			} else {
				mMovie.fps = fps;
				mMovie.play();
			}
			
			if ( flip ){
				mMovie.scaleX = -1.0;
				mMovie.x = mMovie.width;
			} else {
				mMovie.scaleX = 1.0;
				mMovie.x = 0;
			}
			
			if( mMovie != _current ){
				for each( var mov: MovieClip in _movies ) {
					mov.visible = mov == mMovie;
					if( mov != mMovie )
						mov.stop();
				}
			}
			_current = mMovie;
		}
		
		
		override public function setup(): void {
			_atlas = ResourceManager.getTextureAtlas(atlas, spritesheet);
			if ( defaultAnimation != '' )
				play( defaultAnimation );
			owner.addChild(_root);
		}
		
		override public function cleanup(): void {
			owner.removeChild(_root);
			for each (var m : MovieClip in _movies ){
				Starling.juggler.remove( m );
			}
		}
	}

}