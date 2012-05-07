package systems 
{
	import Box2D.Common.Math.b2Vec2;
	import components.Physics;
	import core.Definitions;
	import core.Entity;
	import core.System;
	import core.Systems;
	
	import core.Clock;
	import utils.Serializer;
	
	import components.Margin;
	import components.Spawner;
	
	public class LevelLimits extends System
	{
		
		public function LevelLimits( systems : Systems ) 
		{
			super( systems );
		}
		
		override public function processOneGameTick( clock : Clock ): void {
			var ca : Array = sys.em.getAllComponentsOfType( Margin );
			
			var bottomLimit: Number = 0;
			
			for each ( var m : Margin in ca ) {
				if ( m.owner.y > bottomLimit ) {
					bottomLimit = m.owner.y;
				}
			}
			
			var ens : Array = sys.em.getAllEntities();
			for each (var en : Entity in ens ) {
				if ( en.name == 'background' ) continue;
				if ( en.hasComponent( Margin ) ) continue;
				if ( en.hasComponent( Physics )) {
					var phys :Physics = en.$(Physics) as Physics;
					if ( !( phys.isDynamic || phys.isKinematic ) )
						continue; // don't remove static objects
				} else { 
					continue; // don't remove non-physical components
				}
				if ( en.y > bottomLimit ) {
					sys.em.removeEntity( en );
					en.parent.removeChild(en, true);
				}
			}  
			
			ca = sys.em.getAllComponentsOfType( Spawner );
			for each ( var s : Spawner in ca ) {
				var count: Number = 0;
				for each(en in ens) {
					if ( en.template == s.toSpawn ) {
						count += 1;
						if ( count >= s.limit) break;
					}
				}
				if ( count < s.limit ) {
					var template : XML = Definitions.getTemplates()[s.toSpawn];
					var e :Entity = Serializer.createEntity(template, sys);
					e.isDynamic = true;
					sys.root.addChild(e);
					e.x = s.owner.x;
					e.y = s.owner.y;
					e.template = s.toSpawn;
					if( e.hasComponent(Physics) )
						(e.$(Physics) as Physics).setPosition(b2Vec2.Make(e.x, e.y));
				}
			}
		}
	}

}