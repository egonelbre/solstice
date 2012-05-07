package utils 
{
	// Box2D fixture for serialization
	public class Fixture 
	{
		public var type : String = "POLYGON";
		
		public var density : Number = 1.0;
		public var restitution : Number = 0.5;
		public var friction : Number = 0.5;
		public var isSensor : Boolean = false;
		public var sensorId : String = "";
		
		public var circleRadius : Number = 0;
		public var circleX : Number = 0;
		public var circleY : Number = 0;
		
		public var polygons : Array = [];
		
		public function serialize() : XML {
			var writer : Serializer = new Serializer();
			writer.xml.setName("fixture");
			writer.xml.@type = type;
			
			writer.addNumber('density', density);
			writer.addNumber('restitution', restitution);
			writer.addNumber('friction', friction);
			writer.addBoolean('isSensor', isSensor);
			if( isSensor )
				writer.addString('sensorId', sensorId);
			
			if ( type == "CIRCLE" ) {
				var p : XML = writer.addString('circle', "");
				p.@radius = circleRadius;
				p.@x = circleX;
				p.@y = circleY;
			} else {
				for each( var poly : Array in polygons )
					writer.addString("polygon", poly.toString() );
			}
			return writer.xml;
		}
		
		public function unserialize( data : XML ) : void {
			type = data.@type;
			for each (var e : XML in data.elements() ) {
				if ( e.name() == "density" ) {
					density = parseFloat(e.toString());
				} else if ( e.name() == "restitution" ) {
					restitution = parseFloat(e.toString());
				} else if ( e.name() == "friction" ) {
					friction = parseFloat(e.toString());
				} else if ( e.name() == "isSensor" ) {
					isSensor = e.toString() == "true";
				} else if ( e.name() == "sensorId" ) {
					sensorId = e.toString();
				} else if ( e.name() == "circle" ) {
					circleRadius = parseFloat(e.@radius);
					circleX = parseFloat(e.@x);
					circleY = parseFloat(e.@y);
				} else if ( e.name() == "polygon" ) {
					var poly : Array = [];
					var vertices : Array = (e.toString()).split(",");
					for ( var i : Number = 0; i < vertices.length; i += 1 ) {
						poly.push( parseFloat( vertices[i] ) );
					}
					polygons.push( poly );
				} else {
					trace("UNKNOWN TAG ", e.name(), " IN Fixture serialization.");
				}
			}
		}
	}

}