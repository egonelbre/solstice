package components 
{
	import core.Component;

	public class Layer extends Component
	{
		[Serialize]
		public var z : int = 0;
		[Serialize]
		public var fixed : Boolean = false;
		[Serialize]
		public var noZoom : Boolean = false;
		
		public function Layer() 
		{
			super();
		}
		
		public function init(z: int): Component
		{
			this.z = z;
			return this;
		}
	}

}