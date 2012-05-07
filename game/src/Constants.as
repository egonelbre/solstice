package  
{
	//import flash.filesystem.File;
	
	public class Constants 
	{
		public static const GameWidth: int = 1024;
		public static const GameHeight: int = 768;
		
		public static const CenterX: int = GameWidth / 2;
		public static const CenterY: int = GameHeight / 2;
		
		public static const EntityPanelScrollAmount: int = 40;
		
		public static const FPS: int = 30;
		
		public static const TimeStep: Number = 1.0/FPS;
		public static const SimulationScale: Number = 0.007;
		
		//public static var DataDir: String = File.applicationDirectory.nativePath.replace("/bin", "/data/").replace("\\bin", "\\data\\");
	}

}