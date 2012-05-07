package core 
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	
	import flash.media.Sound;
	
	/*import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;*/
	
	import flash.utils.Timer;
	
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;
	
	import flash.events.Event;
	
	import starling.textures.Texture;
	import starling.textures.TextureAtlas;
	import starling.text.TextField;	
	import starling.text.BitmapFont;
	
	public class ResourceManager 
	{
		private static var assetBundles : Array;
		
		private static var sTextures : Object = new Object();
		private static var sSounds   : Object = new Object();
		private static var sAtlases  : Object = new Object();
		private static var sXML      : Object = new Object();
		
		//
		// assetBundle is either
		// a static class with embed contents
		// or a object with getAsset method
		//
		public static function initialize( assetBundles : Array ): void
		{
			ResourceManager.assetBundles = assetBundles;
		}
		
		public static function clearCache(): void
		{
			sTextures = new Object();
			sSounds   = new Object();
			sAtlases  = new Object();
			sXML      = new Object();
		}
		
		/*public static function getDataPath( filename : String ) : String
		{
			return Constants.DataDir + filename;
		}*/
		
		public static function sanitize( filename : String ): String
		{
			return filename.replace(/[.\/\\\:\-]/g, '_');
		}
		
		/*
		public static function getFileToString( filename : String ):  String
		{
			var file:File = new File(filename);
			var fs:FileStream = new FileStream();
			trace (filename)
			fs.open(file, FileMode.READ);
			var data : String = fs.readUTFBytes(fs.bytesAvailable);
			fs.close();
			return data;
		}*/
		
		/*public static function getFileToBytes( filename : String ): ByteArray
		{
			var file:File = new File(filename);
			var fs:FileStream = new FileStream();
			fs.open(file, FileMode.READ);
			
			var bytes: ByteArray = new ByteArray();
			fs.readBytes(bytes);
			fs.close();
			
			return bytes;
		}*/
		
		private static function getObjectFromAssets( name : String, showError: Boolean = true ) : Object
		{
			for each(var assetBundle : * in assetBundles ) 
			{
				var asset : Object;
				if ( assetBundle is Class ) {
					var assetClass : Class = assetBundle[ name ];
					if ( assetClass == null )
						continue;
					asset = new assetClass();
				} else {
					asset = assetBundle.getAsset( name );
					if ( asset == null )
						continue;
				}
				return asset;
			}
			if( showError )
				trace( 'ASSET NOT FOUND: ', name );
			return null;
		}
		
		public static function getTexture( filename : String ): Texture 
		{
			var name : String = sanitize( filename );
			if (sTextures[name] == undefined)
			{
				var data : Object = getObjectFromAssets( name );
				if (data is Bitmap)
					sTextures[name] = Texture.fromBitmap(data as Bitmap);
				else if (data is ByteArray)
					sTextures[name] = Texture.fromAtfData(data as ByteArray)
				else if (data is Texture)
					sTextures[name] = data;
			}
			return sTextures[ name ] as Texture;
		}
		
		public static function getSound( filename : String ): Sound 
		{
			var name : String = sanitize(filename);
			if (sSounds[name] == undefined)
			{
				var data : Object = getObjectFromAssets( name );
				sSounds[name] = data;
			}
			return sSounds[ name ] as Sound;
		}
		
		public static function getTextureAtlas(xmlFile : String, textureFile : String):TextureAtlas
		{
			var name : String = sanitize( xmlFile );
			if (sAtlases[ name ] == null)
			{   
				var texture : Texture = getTexture(textureFile);
				var xml : XML = loadXML(xmlFile);
				sAtlases[ name ] = new TextureAtlas(texture, xml);
			}
			return sAtlases[ name ] as TextureAtlas;
		}
		
		public static function loadXML( filename : String ): XML
		{
			var xml : XML = XML(getObjectFromAssets( sanitize(filename), false ));
			//if ( xml == null )
				//xml = XML(getFileToString( getDataPath(filename)));
			return xml;
		}
		
		public static function saveXML( filename : String, data : XML ): void
		{
			/*var newFile : File = new File(getDataPath(filename));
			var stream : FileStream = new FileStream();
			stream.open( newFile, FileMode.WRITE );
			stream.writeUTFBytes( data.toString() );
			stream.close();*/
		}
		
		public static function saveAsXML( filename : String, data : XML ): void
		{
			/*var dataDir : File = new File( Constants.DataDir + "/" + filename );
			try {
				dataDir.browseForSave('Save As');
				dataDir.addEventListener(Event.SELECT,
					function(ev : Event): void {
						var newFile : File = ev.target as File;
						var stream : FileStream = new FileStream();
						stream.open( newFile, FileMode.WRITE );
						stream.writeUTFBytes( data.toString() );
						stream.close();
					});
			}
			catch ( error : Error )
			{
				trace( "failed:", error.message );
			}*/
		}
	}

}