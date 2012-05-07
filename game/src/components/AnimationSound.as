package components 
{
	import core.Component;
	
	public class AnimationSound extends Component
	{
		[Serialize]
		public var animation: String = "";
		[Serialize]
		public var frames : Array = [];
		[Serialize]
		public var sound : String = "";
		
		public function AnimationSound() 
		{
			super();
		}
	}

}