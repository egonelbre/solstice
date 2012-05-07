package machines 
{
	import components.Machine;
	import core.Entity;
	
	public class MachineCode
	{
		protected var sm : Machine = null;
		protected var entity : Entity = null;
		
		public function MachineCode(stateMachine : Machine, entity : Entity)
		{
			super();
			this.sm = stateMachine;
			this.entity = entity;
		}
		
		dynamic public function setup(): void {
		}
		
		dynamic public function cleanup(): void {
		}
		
		dynamic public function pre_serialize(): void {}
		dynamic public function post_unserialize(): void { }
		
		dynamic public function update( dt : Number ):void {}
	}

}