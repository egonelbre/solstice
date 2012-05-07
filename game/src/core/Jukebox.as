package core 
{
	import core.Definitions;
	import flash.media.Sound;
	import flash.media.SoundChannel;
	 
	public class Jukebox 
	{
		private static var sound : Sound;
		private static var channel : SoundChannel;
		
		public static function play(name:String) : void {
			var soundtrack: Object = Definitions.getSoundtrack();
			if ( soundtrack == null ) {
				trace( 'soundtrack not found' );
				return;
			}
			sound = ResourceManager.getSound(soundtrack[name].@filename);
			if (channel != null) {
				channel.stop();
			}
			channel = sound.play();
		}
		
		public static function stop(): void {
			if ( channel != null )
				channel.stop();
		}
	}

}