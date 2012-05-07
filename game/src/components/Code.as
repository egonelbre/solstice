package components 
{
	import core.Component;
	
	public class Code extends Component
	{
		public var method : Function = null;
		
		public function Code()
		{
			super();
		}
		
		public function init( method: Function ): Component
		{
			this.method = method;
			return this;
		}
		
		public function run(): void {
			method();
		}
	}

}