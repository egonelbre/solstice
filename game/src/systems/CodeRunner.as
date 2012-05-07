package systems 
{
	import components.Code;
	import core.System;
	import core.Systems;
	
	import core.Clock;
	
	public class CodeRunner extends System
	{
		
		public function CodeRunner( systems : Systems ) 
		{
			super( systems );
		}
		
		override public function processOneGameTick( clock : Clock ): void {
			var ca : Array = sys.em.getAllComponentsOfType( Code );
			for each ( var c : Code in ca ) {
				c.run();
			}
		}
	}

}