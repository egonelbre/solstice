package  
{
	import components.*;
	import systems.*;
	import machines.*;

	// force including classes in swf	
	public class Includer 
	{
		public static var coms : Array = [ 
			Animation, 
			AnimationSound,
			CameraTrack,
			Code,
			Layer,
			Physics,
			Texture,
			Machine,
			Margin,
			Spawner,
			Collectable
		];
		
		public static var syss : Array = [ 
			Box2DWorld,
			Camera,
			CodeRunner,
			StateMachineRunner,
			LevelLimits
		];
		
		public static var machs : Array = [ 
			Girl
		];
		
		public static function init(): void {
		}
	}

}