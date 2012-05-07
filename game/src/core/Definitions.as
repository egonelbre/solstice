package core 
{
	public class Definitions 
	{
		protected static var definitions : Object = new Object();
		
		protected static var templates   : Object = new Object();
		protected static var worlds      : Object = new Object();
		protected static var soundtrack  : Object = new Object();
		protected static var fonts       : Object = new Object();
		
		public static function reload(path: String): void {
			processFile(path);
		}
		
		public static function getTemplates(): Object {
			return templates;
		}
		
		public static function getWorlds(): Object {
			return worlds;
		}	
		
		public static function getSoundtrack(): Object {
			return soundtrack;
		}
		
		protected static function processFile(path: String): XML  {
			var xml : XML = ResourceManager.loadXML(path);
			return processNode(xml);
		}
		
		protected static function processNode(xml: XML): XML {		
			var newchildren: Array = new Array();
			for each (var child: XML in xml.children()) {
				if (child.name() == 'file') {
					var replacement: XML = processFile(child.attribute('filename')); 
					newchildren.push(replacement);
				} else if (child.name() == 'usedef') {
					newchildren.push(definitions[xml.attribute('id')]);
				} else {
					processNode(child);
				}
			}
			// todo: fix the traversal so that <file> and <usedef> nodes get replaced properly
			for each (var elem:XML in newchildren) {
				xml.appendChild(elem);
			}

			// reference certain data with their ids
			if (xml.name() == 'def') {
				definitions[xml.attribute('id')] = xml
			} else if (xml.name() == 'template') {
				templates[xml.@id] = xml;
			} else if (xml.name() == 'music') {
				soundtrack[xml.attribute('id')] = xml;
			} else if (xml.name() == 'world') {
				worlds[xml.attribute('id')] = xml;
			} else if (xml.name() == 'font') {
				fonts[xml.attribute('id')] = xml;
			}
			
			return xml;
		}
		
		// count the number of elements in a dctionary
		public static function countKeys(myDictionary:Object):int 
		{
			var n:int = 0;
			for (var key:* in myDictionary) {
				n++;
			}
			return n;
		}
		
		public static function getKeys(d:Object):void {
			for (var key:* in d) {
				trace ('key: ' + key + ' val:' + d[key]);
			}
		}
	}
}