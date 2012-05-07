package core 
{	
	import utils.Serializer;
	public class System 
	{
		protected var sys : Systems;
		
		public function System( systems : Systems ) : void {
			sys = systems;
			sys.addSystem( this );
		}
		
		public function processOneGameTick( clock : Clock ): void {
			
		}
		
		dynamic public function cleanup(): void {
			
		}
		
		public function serialize(): XML
		{
			return Serializer.serializeObject(this, "system");
		}
		
		public function unserialize(data : XML): void
		{
			Serializer.unserializeToObject( data, this );
		}
	}

}