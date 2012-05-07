package core 
{
	import starling.display.Sprite;
	import utils.Serializer;
	
	// alias for the main visual hierahy class
	// does object does not have to be visble
	public class SceneObject extends Sprite
	{
		// should contain x,y, and possibly other SceneObjects
		public function SceneObject()
		{
			super();
		}
		
		public dynamic function serialize(): XML 
		{
			var writer: Serializer = new Serializer();
			
			if( this.name != '' )
				writer.xml.setName(this.name);
			else
				writer.xml.setName("SceneObject");
				
			writer.addNumber("x", x);
			writer.addNumber("y", y);
			//writer.addNumber("scaleX", scaleX);
			//writer.addNumber("scaleY", scaleY);
			writer.addNumber("rotation", rotation);
			
			return writer.xml;
		}
		
		public dynamic function unserialize( data: XML ): void {
			
		}
	}

}