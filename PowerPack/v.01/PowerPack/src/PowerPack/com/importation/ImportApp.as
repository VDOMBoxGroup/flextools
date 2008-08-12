package PowerPack.com.importation
{
	import ExtendedAPI.com.utils.Utils;
	
	import PowerPack.com.graph.GraphCanvas;
	import PowerPack.com.graph.Node;
	import PowerPack.com.graph.NodeCategory;
	import PowerPack.com.graph.NodeType;
	
	import flash.events.EventDispatcher;
	
	import mx.utils.StringUtil;

	public class ImportApp extends EventDispatcher
	{
		public function ImportApp(app:XML)
		{
			super();
			
			this.appXML = app;
		}
		
		public var appXML:XML;
		
		public function parseIndex():GraphCanvas
		{
			var elms:XMLList = appXML.elements("*");
			var dynElms:Object = {
				'Name':true,
				'Description':true
			};			
			
			var newGraph:GraphCanvas = new GraphCanvas();
			newGraph.category = 'application';
			newGraph.initial = true;
			newGraph.name = 'IndexApplication';
			
			var xOffset:Number = 10;
			var yOffset:Number = 10;
			
			var prev:Node;
			var memNode:Node;
			var node:Node = new Node(NodeCategory.NORMAL, NodeType.INITIAL, '<?xml version="1.0" ?>');
			node.x = xOffset; node.y = yOffset;			
			newGraph.addChild(node);
			
			yOffset += 40;
			
			prev = node;
			node = new Node(NodeCategory.NORMAL, NodeType.NORMAL, '\n\n<Application>');
			node.x = xOffset; node.y = yOffset;
			newGraph.addChild(node);
			newGraph.createArrow(prev, node);
			
			for each(var elm:XML in elms)
			{
				if(dynElms[elm.name()])
				{
				}
				else
				{
					if(elm.name()=='Information') {
						parseInformation();
					}
					else
					{
						/*yOffset += 40;

						prev = node;
						node = new Node(NodeCategory.NORMAL, NodeType.NORMAL, '\n<' + elm.name() + '>');
						node.x = xOffset; node.y = yOffset;
						newGraph.addChild(node);
						newGraph.createArrow(prev, node);*/

						yOffset += 40;

						prev = node;
						node = new Node(NodeCategory.SUBGRAPH, NodeType.NORMAL, elm.name());
						node.x = xOffset; node.y = yOffset;
						newGraph.addChild(node);
						newGraph.createArrow(prev, node);

						/*yOffset += 40;

						prev = node;
						node = new Node(NodeCategory.NORMAL, NodeType.NORMAL, '\n</' + elm.name() + '>');
						node.x = xOffset; node.y = yOffset;
						newGraph.addChild(node);
						newGraph.createArrow(prev, node);*/
					}
				}	
			}			
			
			yOffset += 40;
			
			prev = node;
			node = new Node(NodeCategory.NORMAL, NodeType.TERMINAL, '\n</Application>');
			node.x = xOffset; node.y = yOffset;
			newGraph.addChild(node);
			newGraph.createArrow(prev, node);
			
			return newGraph;
			
			function parseInformation():void {
				for each(var infElm:XML in elm.elements('*'))
				{
					if(dynElms[infElm.name()])
					{
						yOffset += 40;

						prev = node;
						node = new Node(NodeCategory.COMMAND, NodeType.NORMAL, 
							StringUtil.substitute('$ans = [question "Do you want to personalize the Application {0}?" "Yes,No"]', infElm.name()));
						node.x = xOffset; node.y = yOffset;
						newGraph.addChild(node);
						newGraph.createArrow(prev, node);
						
						yOffset += 40;

						prev = node;
						node = new Node(NodeCategory.COMMAND, NodeType.NORMAL, '$ans == "Yes"');
						node.x = xOffset; node.y = yOffset;
						node.arrTrans = ['true', 'false'];
						newGraph.addChild(node);
						newGraph.createArrow(prev, node);
						
						xOffset += 100;
						yOffset += 40;

						prev = node;
						memNode = node = new Node(NodeCategory.COMMAND, NodeType.NORMAL, 	
							StringUtil.substitute('${0} = "{1}"', String(infElm.name()).toLowerCase(), infElm));
						node.x = xOffset; node.y = yOffset;
						newGraph.addChild(node);
						newGraph.createArrow(prev, node, 'false');
						
						xOffset -= 100;
						yOffset += 30;

						node = new Node(NodeCategory.COMMAND, NodeType.NORMAL, 	
							StringUtil.substitute('${0} = [question "Enter application {1}:" "*"]', String(infElm.name()).toLowerCase(), infElm.name()));
						node.x = xOffset; node.y = yOffset;
						newGraph.addChild(node);
						newGraph.createArrow(prev, node, 'true');

						yOffset += 40;

						prev = node;
						node = new Node(NodeCategory.NORMAL, NodeType.NORMAL,
							StringUtil.substitute('\n\t<{0}>${1}</{0}>', infElm.name(), String(infElm.name()).toLowerCase()));
						node.x = xOffset; node.y = yOffset;
						newGraph.addChild(node);
						newGraph.createArrow(memNode, node);												
						newGraph.createArrow(prev, node);
					}
					else
					{
						yOffset += 40;

						prev = node;
						node = new Node(NodeCategory.NORMAL, NodeType.NORMAL, 
							StringUtil.substitute('\n\t<{0}>{1}</{0}>', infElm.name(), infElm));
						node.x = xOffset; node.y = yOffset;
						newGraph.addChild(node);
						newGraph.createArrow(prev, node);
					}	
				}			
			}
		}		
		
		public function parseStructure():Array
		{
			var arr:Array = [];
			
			// STRUCTURE OBJECT
			
			var newGraph:GraphCanvas = new GraphCanvas();
			newGraph.category = 'structure';
			newGraph.name = 'Structure';

			var xOffset:Number = 10;
			var yOffset:Number = 10;
			
			var prev:Node;
			var memNode:Node;
			var node:Node = new Node(NodeCategory.COMMAND, NodeType.INITIAL, '$StructureList = "[]"');
			node.x = xOffset; node.y = yOffset;			
			newGraph.addChild(node);			

			if(XMLList(appXML.Structure).length()>0)
				var struct:XML = appXML.Structure[0];			 
			
			if(struct)
			{			
				var i:int = 1;

				for each(var objSrc:XML in struct.elements('*'))
				{
					yOffset += 40;
					
					prev = node;
					node = new Node(NodeCategory.COMMAND, NodeType.NORMAL, 
						StringUtil.substitute('$obj_{0} = "[{1} {2} {3} {4}]"', 
							i, 
							Utils.getStringOrDefault(objSrc.@ID, "''"),
							Utils.getStringOrDefault(objSrc.@Top, '0'),
							Utils.getStringOrDefault(objSrc.@Left, '0'),
							Utils.getStringOrDefault(objSrc.@ResourceID, "''")));
					node.x = xOffset; node.y = yOffset;
					newGraph.addChild(node);
					newGraph.createArrow(prev, node);
					
					i++;
				}
					
				i = 1;					
				for each(objSrc in struct.elements('*'))
				{					
					yOffset += 20;
					
					for each(var lvl:XML in objSrc.Level)
					{
						var lvlIndex:int = lvl.@Index;
						
						for each(var tgt:XML in lvl.Object)
						{
							yOffset += 40;
							
							prev = node;
							node = new Node(NodeCategory.COMMAND, NodeType.NORMAL, 
								StringUtil.substitute('$StructureList = [addStructure $obj_{0} "{1}" {2} $StructureList]', 
									i, 
									tgt.@ID,
									lvlIndex));
							node.x = xOffset + 50*lvlIndex; node.y = yOffset;
							newGraph.addChild(node);
							newGraph.createArrow(prev, node);
						}						
					}
					
					i++;
				}

			}

			yOffset += 40;
			
			prev = node;
			node = new Node(NodeCategory.SUBGRAPH, NodeType.TERMINAL, 
				'ParseStructure');
			node.x = xOffset; node.y = yOffset;
			newGraph.addChild(node);
			newGraph.createArrow(prev, node);
						
			arr.push(newGraph);

			// PARSE STRUCTURE
			
			var memNode1:Node;
			var memNode2:Node;
			var memNode3:Node;
			
			newGraph = new GraphCanvas();
			newGraph.category = 'structure';
			newGraph.name = 'ParseStructure';

			xOffset = 10;
			yOffset = 10;
			
			node = new Node(NodeCategory.NORMAL, NodeType.INITIAL, '\n<Structure>');
			node.x = xOffset; node.y = yOffset;
			newGraph.addChild(node);
			
			yOffset +=40;
			
			prev = node;
			memNode1 = node = new Node(NodeCategory.COMMAND, NodeType.NORMAL, '$strLstLen = [length $StructureList]');
			node.x = xOffset; node.y = yOffset;
			newGraph.addChild(node);
			newGraph.createArrow(prev, node);

			yOffset +=40;
			
			prev = node;
			memNode1 = node = new Node(NodeCategory.COMMAND, NodeType.NORMAL, '$strLstLen > 0');
			node.arrTrans = ['true', 'false'];
			node.x = xOffset; node.y = yOffset;
			newGraph.addChild(node);
			newGraph.createArrow(prev, node);
			
			xOffset +=100;
			yOffset +=40;
			
			prev = node;
			node = new Node(NodeCategory.COMMAND, NodeType.NORMAL, '$TopLevelList = [get $strLstLen $StructureList]');
			node.x = xOffset; node.y = yOffset;
			newGraph.addChild(node);
			newGraph.createArrow(prev, node, 'true');
			
			yOffset +=40;
			
			prev = node;
			node = new Node(NodeCategory.COMMAND, NodeType.NORMAL, '$ObjectSrcList = [get 1 $TopLevelList]');
			node.x = xOffset; node.y = yOffset;
			newGraph.addChild(node);
			newGraph.createArrow(prev, node);

			yOffset +=40;
			
			prev = node;
			node = new Node(NodeCategory.COMMAND, NodeType.NORMAL, '$LevelLinkList = [get 2 $TopLevelList]');
			node.x = xOffset; node.y = yOffset;
			newGraph.addChild(node);
			newGraph.createArrow(prev, node);

			xOffset +=100;
			yOffset +=40;
			
			prev = node;
			node = new Node(NodeCategory.COMMAND, NodeType.NORMAL, '$srcID = [get 1 $ObjectSrcList]');
			node.x = xOffset; node.y = yOffset;
			newGraph.addChild(node);
			newGraph.createArrow(prev, node);

			yOffset +=40;
			
			prev = node;
			node = new Node(NodeCategory.COMMAND, NodeType.NORMAL, '$srcTop = [get 2  $ObjectSrcList]');
			node.x = xOffset; node.y = yOffset;
			newGraph.addChild(node);
			newGraph.createArrow(prev, node);

			yOffset +=40;
			
			prev = node;
			node = new Node(NodeCategory.COMMAND, NodeType.NORMAL, '$srcLeft = [get 3 $ObjectSrcList]');
			node.x = xOffset; node.y = yOffset;
			newGraph.addChild(node);
			newGraph.createArrow(prev, node);

			yOffset +=40;
			
			prev = node;
			node = new Node(NodeCategory.COMMAND, NodeType.NORMAL, '$srcResId = [get 4 $ObjectSrcList]');
			node.x = xOffset; node.y = yOffset;
			newGraph.addChild(node);
			newGraph.createArrow(prev, node);
			
			yOffset +=40;
			
			prev = node;
			node = new Node(NodeCategory.NORMAL, NodeType.NORMAL, 
				'\n\t<Object ID="$srcID" Top="$srcTop" Left="$srcLeft" ResourceID="$srcResId">');
			node.x = xOffset; node.y = yOffset;
			newGraph.addChild(node);
			newGraph.createArrow(prev, node);				

			//////////////////////////////////////////
			
			yOffset +=40;
			
			prev = node;
			node = new Node(NodeCategory.COMMAND, NodeType.NORMAL, '$lvlLstLen = [length $LevelLinkList]');
			node.x = xOffset; node.y = yOffset;
			newGraph.addChild(node);
			newGraph.createArrow(prev, node);				
			
			yOffset +=40;
			
			prev = node;
			memNode2 = node = new Node(NodeCategory.COMMAND, NodeType.NORMAL, '$lvlLstLen > 0');
			node.arrTrans = ['true', 'false'];
			node.x = xOffset; node.y = yOffset;
			newGraph.addChild(node);
			newGraph.createArrow(prev, node);				

			xOffset +=100;
			yOffset +=40;
							
			prev = node;
			node = new Node(NodeCategory.COMMAND, NodeType.NORMAL, '$lvlObjTgtList = [get $lvlLstLen $LevelLinkList]');
			node.x = xOffset; node.y = yOffset;
			newGraph.addChild(node);
			newGraph.createArrow(prev, node, 'true');				

			yOffset +=40;
							
			prev = node;
			node = new Node(NodeCategory.COMMAND, NodeType.NORMAL, '$lvlIndex = [get 1 $lvlObjTgtList]');
			node.x = xOffset; node.y = yOffset;
			newGraph.addChild(node);
			newGraph.createArrow(prev, node);				

			yOffset +=40;
							
			prev = node;
			node = new Node(NodeCategory.COMMAND, NodeType.NORMAL, '$objTgtList = [get 2 $lvlObjTgtList]');
			node.x = xOffset; node.y = yOffset;
			newGraph.addChild(node);
			newGraph.createArrow(prev, node);				

			yOffset +=40;

			prev = node;
			node = new Node(NodeCategory.NORMAL, NodeType.NORMAL, '\n\t\t<Level Index="$lvlIndex">');
			node.x = xOffset; node.y = yOffset;
			newGraph.addChild(node);
			newGraph.createArrow(prev, node);				

			yOffset +=40;
							
			prev = node;
			node = new Node(NodeCategory.COMMAND, NodeType.NORMAL, '$tgtLstLen = [length $objTgtList]');
			node.x = xOffset; node.y = yOffset;
			newGraph.addChild(node);
			newGraph.createArrow(prev, node);				

			yOffset +=40;
			
			prev = node;
			memNode3 = node = new Node(NodeCategory.COMMAND, NodeType.NORMAL, '$tgtLstLen > 0');
			node.arrTrans = ['true', 'false'];
			node.x = xOffset; node.y = yOffset;
			newGraph.addChild(node);
			newGraph.createArrow(prev, node);
			
			xOffset +=100;
			yOffset +=40;
							
			prev = node;
			node = new Node(NodeCategory.COMMAND, NodeType.NORMAL, '$tgtID = [get $tgtLstLen $objTgtList]');
			node.x = xOffset; node.y = yOffset;
			newGraph.addChild(node);
			newGraph.createArrow(prev, node, 'true');				
			
			yOffset +=40;
							
			prev = node;
			node = new Node(NodeCategory.NORMAL, NodeType.NORMAL, '\n\t\t\t<Object ID="$tgtID" />');
			node.x = xOffset; node.y = yOffset;
			newGraph.addChild(node);
			newGraph.createArrow(prev, node);				
			
			yOffset +=40;
							
			prev = node;
			node = new Node(NodeCategory.COMMAND, NodeType.NORMAL, '$tgtLstLen = $tgtLstLen - 1');
			node.x = xOffset; node.y = yOffset;
			newGraph.addChild(node);
			newGraph.createArrow(prev, node);
			
			newGraph.createArrow(node, memNode3);
			
			xOffset -=100;
			yOffset +=40;
							
			prev = node;
			node = new Node(NodeCategory.NORMAL, NodeType.NORMAL, '\n\t\t</Level>');
			node.x = xOffset; node.y = yOffset;
			newGraph.addChild(node);
			newGraph.createArrow(memNode3, node, 'false');				

			yOffset +=40;
							
			prev = node;
			node = new Node(NodeCategory.COMMAND, NodeType.NORMAL, '$lvlLstLen = $lvlLstLen - 1');
			node.x = xOffset; node.y = yOffset;
			newGraph.addChild(node);
			newGraph.createArrow(prev, node);

			newGraph.createArrow(node, memNode2);
			
			xOffset -=100;
			yOffset +=40;

			prev = node;
			node = new Node(NodeCategory.NORMAL, NodeType.NORMAL, '\n\t</Object>');
			node.x = xOffset; node.y = yOffset;
			newGraph.addChild(node);
			newGraph.createArrow(memNode2, node, 'false');				

			yOffset +=40;
							
			prev = node;
			node = new Node(NodeCategory.COMMAND, NodeType.NORMAL, '$strLstLen = $strLstLen - 1');
			node.x = xOffset; node.y = yOffset;
			newGraph.addChild(node);
			newGraph.createArrow(prev, node);
			
			newGraph.createArrow(node, memNode1);

			xOffset -=100;
			yOffset +=40;
							
			prev = node;
			node = new Node(NodeCategory.NORMAL, NodeType.TERMINAL, '\n</Structure>');
			node.x = xOffset; node.y = yOffset;
			newGraph.addChild(node);
			newGraph.createArrow(memNode1, node, 'false');

			arr.push(newGraph);
			
			return arr;
		}
		
		public function parseObjects():Array
		{
			var arr:Array = [];
			
			var newGraph:GraphCanvas = new GraphCanvas();
			newGraph.category = 'objects';
			newGraph.name = 'Objects';

			var xOffset:Number = 10;
			var yOffset:Number = 10;
			
			var prev:Node;
			var node:Node = new Node(NodeCategory.NORMAL, NodeType.INITIAL, '<!-- Objects -->');
			node.x = xOffset; node.y = yOffset;			
			newGraph.addChild(node);
			
			arr.push(newGraph);
						
			return arr;
		}
		
		public function parseDatabases():Array
		{
			var arr:Array = [];
			
			var newGraph:GraphCanvas = new GraphCanvas();
			newGraph.category = 'databases';
			newGraph.name = 'Databases';

			var xOffset:Number = 10;
			var yOffset:Number = 10;
			
			var prev:Node;
			var node:Node = new Node(NodeCategory.NORMAL, NodeType.INITIAL, '<!-- Databases -->');
			node.x = xOffset; node.y = yOffset;			
			newGraph.addChild(node);
			
			arr.push(newGraph);
						
			return arr;
		}
		
		public function parseResources():Array
		{
			var arr:Array = [];
			
			var newGraph:GraphCanvas = new GraphCanvas();
			newGraph.category = 'resources';
			newGraph.name = 'Resources';

			var xOffset:Number = 10;
			var yOffset:Number = 10;
			
			var prev:Node;
			var node:Node = new Node(NodeCategory.NORMAL, NodeType.INITIAL, '<!-- Resources -->');
			node.x = xOffset; node.y = yOffset;			
			newGraph.addChild(node);
			
			arr.push(newGraph);
						
			return arr;
		}
			
		public function parseE2vdom():Array
		{
			var arr:Array = [];
			
			var newGraph:GraphCanvas = new GraphCanvas();
			newGraph.category = 'E2vdom';
			newGraph.name = 'E2vdom';

			var xOffset:Number = 10;
			var yOffset:Number = 10;
			
			var prev:Node;
			var node:Node = new Node(NodeCategory.NORMAL, NodeType.INITIAL, '<!-- E2vdom -->');
			node.x = xOffset; node.y = yOffset;			
			newGraph.addChild(node);
			
			arr.push(newGraph);
						
			return arr;
		}			
	}
}