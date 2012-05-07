package systems 
{
	import components.Machine;
	import core.System;
	import core.Systems;
	
	import core.Clock;
	
	public class StateMachineRunner extends System
	{
		public function StateMachineRunner( systems : Systems ) 
		{
			super( systems );
		}
		
		override public function processOneGameTick( clock : Clock ): void {
			var ca : Array = sys.em.getAllComponentsOfType( Machine );
			for each ( var sm : Machine in ca ) {
				sm.update( 0.03 );
			}
		}
	}

}