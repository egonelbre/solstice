package components 
{
	import flash.utils.describeType;
	import flash.utils.getDefinitionByName;

	import core.Component;
	
	import machines.MachineCode;
	
	public class Machine extends Component 
	{
		[Serialize]
		public var definition : String = "";
		
		private var machine : MachineCode = null;
		
		public function Machine() 
		{
			super();
		}
		
		override public function setup(): void {
			if( definition != '' ){
				var cls : Class = getDefinitionByName( definition ) as Class;
				machine = new cls( this, this.owner );
				machine.setup();
			}
		}
		
		override public function cleanup(): void {
			if( machine != null )
				machine.cleanup();
		}
		
		public function update( dt : Number ): void {
			if( machine != null )
				machine.update(dt);
		}
	}

}
