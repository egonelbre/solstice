package components 
{
	import starling.display.Image;
	import core.ResourceManager;
	import core.Component;
	
	public class Texture extends Component
	{
		public var _texture : Image;
		
		[Serialize]
		public var x : Number = 0;
		[Serialize]
		public var y : Number = 0;
		[Serialize]
		public var image : String;
		
		public function Texture()
		{
			super();
		}
		
		public function init(name : String) : Component
		{
			image = name;
			return this;
		}
		
		override public function setup(): void {
			_texture = new Image( ResourceManager.getTexture(image) );
			_texture.x = x;
			_texture.y = y;
			owner.addChild(_texture);
		}
		
		override public function cleanup(): void {
			owner.removeChild(_texture);
		}
	}

}