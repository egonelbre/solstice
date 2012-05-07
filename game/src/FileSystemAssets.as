package  
{
	import core.ResourceManager;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Loader;
	import flash.events.Event;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.media.Sound;
	import flash.net.FileReference;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.events.IOErrorEvent;
	import flash.sampler.NewObjectSample;
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;
	import starling.display.Image;
	import starling.textures.Texture;
	
	public class FileSystemAssets 
	{
		private var assets : Object = new Object();
		private var temp_assets : Object = new Object();
		
		private var listing : Boolean = false;
		private var loading_count : Number = 0;
		
		private var onBeforeReload : Function;
		private var onAllLoaded : Function;
		private var onError : Function;
		
		public function FileSystemAssets( onBeforeReload : Function, onAllLoaded : Function, onError:Function ) {
			this.onBeforeReload = onBeforeReload;
			this.onAllLoaded = onAllLoaded;
			this.onError = onError;
		}
		
		private function loadDirectory(dir : File): void 
		{
			for each ( var f : File in dir.getDirectoryListing() )
			{
				if ( f.isDirectory )
					loadDirectory( f )
				else if ( !f.isSymbolicLink && !f.isPackage )
					loadFile( f );
			}
		}
		
		private function loadFile(file : File ): void 
		{
			if ( ".mp3.png.xml.".indexOf(file.extension) < 0 )
				return;
			var relativePath : String = file.nativePath.replace( Constants.DataDir, "" );
			var name : String = ResourceManager.sanitize(relativePath);
			trace( name );
			function onLoaded(e : Event) : void {
				if ( file.extension == "xml" ) {
					try {
						temp_assets[ name ] = XML( e.target.data );
					} catch ( e : Error ) {
						onError('Error loading : ' + name);
					}
				} else {
					temp_assets[ name ] = e.target.data;
				}
				decLoading();
			}
			
			function onMP3Loaded( e : Event ): void {
				temp_assets[ name ] = e.target;
				e.target.removeEventListener( Event.COMPLETE, onMP3Loaded );
				decLoading();
			}
			
			function onPNGLoaded( e : Event ): void {
				var bitmap : Bitmap = e.target.content;	
				try {
					temp_assets[ name ] = Texture.fromBitmapData( bitmap.bitmapData );
				} catch ( e : Error ) {
					onError('Error loading : ' + name);
				}
				e.target.removeEventListener( Event.COMPLETE, onPNGLoaded );
				decLoading();
			}
			
			var req : URLRequest = new URLRequest( file.url );
			incLoading();
			
			if ( file.extension == "png" ) {
				var pngldr : Loader = new Loader();
				pngldr.contentLoaderInfo.addEventListener( Event.COMPLETE, onPNGLoaded );
				pngldr.load( req );
			} else if ( file.extension == "mp3" ) {
				var mp3ldr : Sound = new Sound();
				mp3ldr.addEventListener( Event.COMPLETE, onMP3Loaded );
				mp3ldr.load(req);
			} else {
				var ldr : URLLoader = new URLLoader();
				ldr.addEventListener( Event.COMPLETE, onLoaded );
				ldr.dataFormat = URLLoaderDataFormat.BINARY;
				ldr.load(req);
			}
		}
		
		public function reload(): void
		{
			if ( loading_count > 0 ) {
				trace( "ALREADY LOADING DATA" );
				return;
			}
			onBeforeReload();
			listing = true;
			temp_assets = new Object();
			var root : File = new File( Constants.DataDir );
			loadDirectory( root );
			listing = false;
		}
		
		private function incLoading(): void {
			loading_count += 1;
		}
		
		private function decLoading(): void {
			loading_count -= 1;
			if ( (loading_count == 0) && !listing)
				loadingDone();
		}
		
		private function loadingDone(): void
		{
			assets = temp_assets;
			temp_assets = null;
			onAllLoaded();
		}
		
		public function getAsset( name : String ): Object {
			if ( assets[ name ] == undefined )
				return null;
			return assets[ name ];
		}
	}

}