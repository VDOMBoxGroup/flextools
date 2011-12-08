package net.vdombox.powerpack.importation
{
	import net.vdombox.powerpack.lib.ExtendedAPI.utils.Utils;
	
	import net.vdombox.powerpack.Template;
	import net.vdombox.powerpack.graph.GraphCanvas;
	import net.vdombox.powerpack.graph.Node;
	import net.vdombox.powerpack.graph.NodeCategory;
	import net.vdombox.powerpack.graph.NodeType;
	import net.vdombox.powerpack.managers.CashManager;
	
	import flash.events.EventDispatcher;
	
	import mx.utils.StringUtil;
	import mx.utils.UIDUtil;

	public class ImportApp extends EventDispatcher
	{
		public function ImportApp(app:XML, types:XML)
		{
			super();
			
			this.appXML = app;
			this.typesXML = types;
		}
		
		public var template:Template = new Template();
		
		public var appXML:XML;
		
		public var typesXML:XML;

		public var typeNameMap:Object = {
			'bar':'Bar',
			'bgmusic':'BgMusic',
			'button':'Button',
			'calendar':'Calendar', 
			'contact':'Contact',
			'container':'Container',
			'copy':'Copy',
			'database':'Database',
			'dbhtmlview':'DbHtmlView',
			'dbschema':'DbSchema',
			'dbtable':'DbTable',
			'debug':'Debug',
			'flashanimation':'FlashAnimation',
			'flashbook':'FlashBook',
			'form':'Form',
			'formbutton':'FormButton',
			'formcheckbox':'FormCheckBox',
			'formdropdown':'FormDropDown',
			'formpassword':'FormPassword',
			'formradiobutton':'FormRadioButton',
			'formradiogroup':'FormRadioGroup',
			'formtext':'FormText',
			'htmlcontainer':'HtmlContainer',
			'hypertext':'HyperText',
			'image':'Image',
			'menu':'Menu',
			'menucontainer':'MenuContainer',
			'menufooter':'MenuFooter',
			'menuheader':'MenuHeader',
			'menuitem':'MenuItem',
			'password':'Password',
			'printtowebcontainer':'PrintToWebContainer',
			'printtowebscript':'PrintToWebScript',
			'sensitive':'Sensitive',
			'table':'Table',
			'tablecell':'TableCell',
			'tablerow':'TableRow',
			'text':'Text',
			'time':'Time',
			'whole':'Whole',
			'wire':'Wire'
		}
			
		public var objCounter:Object = {};
		
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
			newGraph.name = 'ApplicationIndex';
			
			var xOffset:Number = 10;
			var yOffset:Number = 10;
			
			var prev:Node;
			var memNode:Node;
			var node:Node = new Node(NodeCategory.NORMAL, NodeType.INITIAL, '<?xml version="1.0" ?>');
			node.x = xOffset; node.y = yOffset;			
			newGraph.addChild(node);
			
			yOffset += 40;
			
			prev = node;
			node = new Node(NodeCategory.NORMAL, NodeType.NORMAL, '\\n\\n<Application>');
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
			node = new Node(NodeCategory.NORMAL, NodeType.TERMINAL, '\\n</Application>');
			node.x = xOffset; node.y = yOffset;
			newGraph.addChild(node);
			newGraph.createArrow(prev, node);
			
			return newGraph;
			
			function parseInformation():void {

				yOffset += 40;

				prev = node;
				node = new Node(NodeCategory.NORMAL, NodeType.NORMAL, '\\n<Information>');
				node.x = xOffset; node.y = yOffset;
				newGraph.addChild(node);
				newGraph.createArrow(prev, node);
						
				for each(var infElm:XML in elm.elements('*'))
				{
					if(dynElms[infElm.name()])
					{
						yOffset += 40;

						prev = node;
						node = new Node(NodeCategory.COMMAND, NodeType.NORMAL, 
							StringUtil.substitute('$ans = [question "Do you want to personalize the Application {0}?" "Yes" "No"]', 
							infElm.name()));
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
							StringUtil.substitute('\\n\\t<{0}>${1}</{0}>', infElm.name(), String(infElm.name()).toLowerCase()));
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
							StringUtil.substitute('\\n\\t<{0}>{1}</{0}>', infElm.name(), String(infElm).replace(/\n/g, "\\n")));
						node.x = xOffset; node.y = yOffset;
						newGraph.addChild(node);
						newGraph.createArrow(prev, node);
					}	
				}	

				yOffset += 40;

				prev = node;
				node = new Node(NodeCategory.NORMAL, NodeType.NORMAL, '\\n</Information>');
				node.x = xOffset; node.y = yOffset;
				newGraph.addChild(node);
				newGraph.createArrow(prev, node);
						
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
			
			node = new Node(NodeCategory.NORMAL, NodeType.INITIAL, '\\n<Structure>');
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
				'\\n\\t<Object ID="$srcID" Top="$srcTop" Left="$srcLeft" ResourceID="$srcResId">');
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
			node = new Node(NodeCategory.NORMAL, NodeType.NORMAL, '\\n\\t\\t<Level Index="$lvlIndex">');
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
			node = new Node(NodeCategory.NORMAL, NodeType.NORMAL, '\\n\\t\\t\\t<Object ID="$tgtID" />');
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
			node = new Node(NodeCategory.NORMAL, NodeType.NORMAL, '\\n\\t\\t</Level>');
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
			node = new Node(NodeCategory.NORMAL, NodeType.NORMAL, '\\n\\t</Object>');
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

			xOffset -=200;
			yOffset +=40;
							
			prev = node;
			node = new Node(NodeCategory.NORMAL, NodeType.TERMINAL, '\\n</Structure>');
			node.x = xOffset; node.y = yOffset;
			newGraph.addChild(node);
			newGraph.createArrow(memNode1, node, 'false');

			arr.push(newGraph);
			
			return arr;
		}
		
		private function setBaseObject():Array
		{
			var arr:Array = [];
			
			// PARSE OBJECT 
			
			var newGraph:GraphCanvas = new GraphCanvas();
			newGraph.category = 'objects';
			newGraph.name = 'Object';

			var xOffset:Number = 10;
			var yOffset:Number = 10;
			
			var prev:Node;
			var node:Node = new Node(NodeCategory.NORMAL, NodeType.INITIAL, 
				'\\n\\t<Object Type="$param1" ID="$param2" Name="$param3">');
			node.x = xOffset; node.y = yOffset;			
			newGraph.addChild(node);
			
			yOffset +=40;

			prev = node;
			node = new Node(NodeCategory.COMMAND, NodeType.NORMAL, '[sub ParseAttributes $param4]');
			node.x = xOffset; node.y = yOffset;
			newGraph.addChild(node);
			newGraph.createArrow(prev, node);			
			
			yOffset +=40;
			
			prev = node;
			node = new Node(NodeCategory.NORMAL, NodeType.TERMINAL, '\\n\\t</Object>');
			node.x = xOffset; node.y = yOffset;
			newGraph.addChild(node);
			newGraph.createArrow(prev, node);			

			arr.push(newGraph);
			
			// PARSE ATTRIBUTE
			
			newGraph = new GraphCanvas();
			newGraph.category = 'objects';
			newGraph.name = 'ParseAttributes';

			xOffset = 10;
			yOffset = 10;
			
			var memNode1:Node;
			node = new Node(NodeCategory.NORMAL, NodeType.INITIAL, 
				'\\n\\t<Attributes>');
			node.x = xOffset; node.y = yOffset;			
			newGraph.addChild(node);
			
			yOffset +=40;

			prev = node;
			node = new Node(NodeCategory.COMMAND, NodeType.NORMAL, 
				'$attrLstLen = [length $param1]');
			node.x = xOffset; node.y = yOffset;
			newGraph.addChild(node);
			newGraph.createArrow(prev, node);			

			yOffset +=40;

			prev = node;
			memNode1 = node = new Node(NodeCategory.COMMAND, NodeType.NORMAL, 
				'$attrLstLen > 1');
			node.arrTrans = ['true', 'false'];
			node.x = xOffset; node.y = yOffset;
			newGraph.addChild(node);
			newGraph.createArrow(prev, node);			
			
			xOffset +=100;
			yOffset +=40;

			prev = node;
			node = new Node(NodeCategory.COMMAND, NodeType.NORMAL, 
				'$attrName = [get $attrLstLen-1 $param1]');
			node.x = xOffset; node.y = yOffset;
			newGraph.addChild(node);
			newGraph.createArrow(prev, node, 'true');
			
			yOffset +=40;

			prev = node;
			node = new Node(NodeCategory.COMMAND, NodeType.NORMAL, 
				'$attrValue = [get $attrLstLen $param1]');
			node.x = xOffset; node.y = yOffset;
			newGraph.addChild(node);
			newGraph.createArrow(prev, node, 'true');
					
			yOffset +=40;

			prev = node;
			node = new Node(NodeCategory.NORMAL, NodeType.NORMAL, 
				'\\n\\t\\t<Attribute Name="$attrName"><![CDATA[$attrValue]]></Attribute>');
			node.x = xOffset; node.y = yOffset;
			newGraph.addChild(node);
			newGraph.createArrow(prev, node);

			yOffset +=40;

			prev = node;
			node = new Node(NodeCategory.COMMAND, NodeType.NORMAL, 
				'$attrLstLen = $attrLstLen - 2');
			node.x = xOffset; node.y = yOffset;
			newGraph.addChild(node);
			newGraph.createArrow(prev, node);
			
			newGraph.createArrow(node, memNode1);
			
			xOffset -=100;
			yOffset +=40;

			prev = node;
			node = new Node(NodeCategory.NORMAL, NodeType.TERMINAL, '\\n\\t</Attributes>');
			node.x = xOffset; node.y = yOffset;
			newGraph.addChild(node);
			newGraph.createArrow(memNode1, node, 'false');			

			arr.push(newGraph);			
						
			return arr;			
		}		 
		
		private function setObjects():Array
		{
			var arr:Array = setBaseObject();
			
			for each (var type:XML in typesXML.Type)
			{
				if(int(type.Information.Container) == 1)
				{
					var newGraph:GraphCanvas = new GraphCanvas();
					newGraph.category = 'objects';
					newGraph.name = typeNameMap[type.Information.Name] ? typeNameMap[type.Information.Name] : type.Information.Name;
		
					var xOffset:Number = 10;
					var yOffset:Number = 10;
					
					var prev:Node;
					var node:Node = new Node(NodeCategory.COMMAND, NodeType.INITIAL, 
						StringUtil.substitute('[sub Object "{0}" $param1 $param2 $param3]', type.Information.ID));
					node.x = xOffset; node.y = yOffset;			
					newGraph.addChild(node);
					
					arr.push(newGraph);					
				}				
			}
						
			return arr;
		}
		
		public function parseObjects():Array
		{
			var arr:Array = setObjects();
			
			var newGraph:GraphCanvas = new GraphCanvas();
			newGraph.category = 'objects';
			newGraph.name = 'Objects';

			var xOffset:Number = 10;
			var yOffset:Number = 10;
			
			var prev:Node;
			var node:Node = new Node(NodeCategory.NORMAL, NodeType.INITIAL, '\\n<Objects>');
			node.x = xOffset; node.y = yOffset;			
			newGraph.addChild(node);

			if(XMLList(appXML.Objects).length()>0)
				var objs:XML = appXML.Objects[0];			 
			
			if(objs)
			{		
				for each (var obj:XML in objs.Object)
				{
					var type:XML = getType(obj.@Type);
					var objGraphName:String = type ? (typeNameMap[type.Information.Name] ? typeNameMap[type.Information.Name] : type.Information.Name) : obj.@Type;
					 
					/*
					if(type && int(type.Information.Container) == 1)
					{
						yOffset +=40;
						
						var attrLst:String = '[';						
						for each (var attr:XML in obj.Attributes.Attribute) {
							attrLst += ' "'+attr.@Name+'" '+Utils.doubleQuotes(attr);	
						}						
						attrLst += ' ]'; 
						
						prev = node;
						node = new Node(NodeCategory.COMMAND, NodeType.NORMAL, 
							StringUtil.substitute('[sub {0} "{1}" "{2}" {3}]', 
								objGraphName,
								Utils.getStringOrDefault(obj.@ID, ''),
								Utils.getStringOrDefault(obj.@Name, ''),
								Utils.doubleQuotes(attrLst)));
						node.x = xOffset; node.y = yOffset;
						newGraph.addChild(node);
						newGraph.createArrow(prev, node);					
					}
					else
					*/
					
					{
						objCounter[type.Information.Name] = objCounter[type.Information.Name] ? objCounter[type.Information.Name]+1 : 1; 
						var contName:String = objGraphName+'_'+objCounter[type.Information.Name];
						
						yOffset +=40;
						
						prev = node;
						node = new Node(NodeCategory.SUBGRAPH, NodeType.NORMAL, String(contName).replace(/\n/g, "\\n"));
						node.x = xOffset; node.y = yOffset;
						newGraph.addChild(node);
						newGraph.createArrow(prev, node);					

						parseObjectsRecursive(contName, obj, arr);					
					}						
				}
			}	
					
			yOffset +=40;
							
			prev = node;
			node = new Node(NodeCategory.NORMAL, NodeType.TERMINAL, '\\n</Objects>');
			node.x = xOffset; node.y = yOffset;
			newGraph.addChild(node);
			newGraph.createArrow(prev, node);
			
			arr.push(newGraph);
						
			return arr;
		}
		
		private function getType(objType:String):XML
		{				
			return typesXML.Type.(String(Information.ID).toLowerCase() == objType.toLowerCase())[0];	
		} 
		
		private function parseObjectsRecursive(graphName:String, curObj:XML, graphs:Array, category:String=null):void
		{
			var newGraph:GraphCanvas = new GraphCanvas();
			newGraph.category = category ? category : (curObj.@Name ? curObj.@Name : graphName);
			newGraph.name = graphName;

			var xOffset:Number = 10;
			var yOffset:Number = 10;
			
			var prev:Node;
			var node:Node = new Node(NodeCategory.NORMAL, NodeType.INITIAL, 
				StringUtil.substitute('\\n\\t<Object ID="{0}" Name="{1}" Type="{2}">',
					Utils.getStringOrDefault(curObj.@ID, ''),
					Utils.getStringOrDefault(curObj.@Name, ''), 
					Utils.getStringOrDefault(curObj.@Type, '')));
			node.x = xOffset; node.y = yOffset;
			newGraph.addChild(node);
			
			// Parse Attributes
			
			
			var attrLst:String = '[';			
			for each (var attr:XML in curObj.Attributes.Attribute) {
				attrLst += ' "'+attr.@Name+'" '+Utils.quotes(attr).replace(/\n/g, "\\n");	
			}			
			attrLst += ' ]';						
			
			yOffset +=40;
			
			prev = node;
			node = new Node(NodeCategory.COMMAND, NodeType.NORMAL, 
				StringUtil.substitute('[sub ParseAttributes {0}]',
					Utils.quotes(attrLst, true).replace(/\n/g, "\\n")));
			node.x = xOffset; node.y = yOffset;
			newGraph.addChild(node);
			newGraph.createArrow(prev, node);			
			
			/*
			// Parse attributes
			
			if(XMLList(curObj.Attributes).length()>0)
				var attrs:XML = curObj.Attributes[0];			
			
			if(attrs && XMLList(curObj.Attributes.Attribute).length()>0)
			{			
				yOffset +=40;
			
				prev = node;
				node = new Node(NodeCategory.NORMAL, NodeType.NORMAL, '\n\t<Attributes>');
				node.x = xOffset; node.y = yOffset;
				newGraph.addChild(node);
				newGraph.createArrow(prev, node);
							
				for each (var attr:XML in attrs.Attribute)
				{
					yOffset +=40;
						
					prev = node;
					node = new Node(NodeCategory.NORMAL, NodeType.NORMAL, 
						'<Attribute Name="' + attr.@Name + '"><![CDATA[\\-');
					node.x = xOffset; node.y = yOffset;
					newGraph.addChild(node);
					newGraph.createArrow(prev, node);					
					
					if(attr && 0)
					{
						yOffset +=40;
						
						prev = node;
						node = new Node(NodeCategory.NORMAL, NodeType.NORMAL, 
							attr);
						node.x = xOffset; node.y = yOffset;
						newGraph.addChild(node);
						newGraph.createArrow(prev, node);
					}
										
					yOffset +=40;
						
					prev = node;
					node = new Node(NodeCategory.NORMAL, NodeType.NORMAL, 
						'\\-]]></Attribute>');
					node.x = xOffset; node.y = yOffset;
					newGraph.addChild(node);
					newGraph.createArrow(prev, node);										
				}

				yOffset +=40;
			
				prev = node;
				node = new Node(NodeCategory.NORMAL, NodeType.NORMAL, '\n\t</Attributes>');
				node.x = xOffset; node.y = yOffset;
				newGraph.addChild(node);
				newGraph.createArrow(prev, node);
			}
			*/

			// Parse objects
			
			if(XMLList(curObj.Objects).length()>0)
				var objs:XML = curObj.Objects[0];			
			
			if(objs && XMLList(curObj.Objects.Object).length()>0)
			{			
				yOffset +=40;
			
				prev = node;
				node = new Node(NodeCategory.NORMAL, NodeType.NORMAL, '\\n\\t<Objects>');
				node.x = xOffset; node.y = yOffset;
				newGraph.addChild(node);
				newGraph.createArrow(prev, node);
							
				for each (var obj:XML in objs.Object)
				{
					var type:XML = getType(obj.@Type);
					var objGraphName:String = typeNameMap[type.Information.Name] ? typeNameMap[type.Information.Name] : type.Information.Name;
					 
					/*
					if(int(type.Information.Container) == 1)
					{
						yOffset +=40;
						
						attrLst = '[';						
						for each (attr in obj.Attributes.Attribute) {
							attrLst += ' "'+attr.@Name+'" '+Utils.doubleQuotes(attr);	
						}						
						attrLst += ' ]';
						
						prev = node;
						node = new Node(NodeCategory.COMMAND, NodeType.NORMAL, 
							StringUtil.substitute('[sub {0} "{1}" "{2}" {3}]', 
								objGraphName,
								Utils.getStringOrDefault(obj.@ID, ''),
								Utils.getStringOrDefault(obj.@Name, ''),
								Utils.doubleQuotes(attrLst)));
						node.x = xOffset; node.y = yOffset;
						newGraph.addChild(node);
						newGraph.createArrow(prev, node);					
					}
					else
					*/
					{
						objCounter[type.Information.Name] = objCounter[type.Information.Name] ? objCounter[type.Information.Name]+1 : 1; 
						var contName:String = objGraphName+'_'+objCounter[type.Information.Name];
						
						yOffset +=40;
						
						prev = node;
						node = new Node(NodeCategory.SUBGRAPH, NodeType.NORMAL, contName.replace(/\n/g, "\\n"));
						node.x = xOffset; node.y = yOffset;
						newGraph.addChild(node);
						newGraph.createArrow(prev, node);					
	
						parseObjectsRecursive(contName, obj, graphs, newGraph.category);					
					}						
				}
				yOffset +=40;
			
				prev = node;
				node = new Node(NodeCategory.NORMAL, NodeType.NORMAL, '\\n\\t</Objects>');
				node.x = xOffset; node.y = yOffset;
				newGraph.addChild(node);
				newGraph.createArrow(prev, node);
			}

			yOffset +=20;
			
			// Parse scripts
			
			if(XMLList(curObj.Scripts).length()>0)
				var scrpts:XML = curObj.Scripts[0];			
			
			if(scrpts && XMLList(curObj.Scripts.Script).length()>0 && 0)
			{			
				yOffset +=40;
			
				prev = node;
				node = new Node(NodeCategory.NORMAL, NodeType.NORMAL, '\n\t<Scripts>');
				node.x = xOffset; node.y = yOffset;
				newGraph.addChild(node);
				newGraph.createArrow(prev, node);
							
				for each (var scrpt:XML in scrpts.Script)
				{
					yOffset +=40;
						
					prev = node;
					node = new Node(NodeCategory.NORMAL, NodeType.NORMAL, 
						'<Script Language="' + scrpt.@Language + '"><![CDATA[\\-');
					node.x = xOffset; node.y = yOffset;
					newGraph.addChild(node);
					newGraph.createArrow(prev, node);					
	
					yOffset +=40;
						
					prev = node;
					node = new Node(NodeCategory.NORMAL, NodeType.NORMAL, 
						scrpt);
					node.x = xOffset; node.y = yOffset;
					newGraph.addChild(node);
					newGraph.createArrow(prev, node);
										
					yOffset +=40;
						
					prev = node;
					node = new Node(NodeCategory.NORMAL, NodeType.NORMAL, 
						'\\-]]></Script>');
					node.x = xOffset; node.y = yOffset;
					newGraph.addChild(node);
					newGraph.createArrow(prev, node);										
				}

				yOffset +=40;
			
				prev = node;
				node = new Node(NodeCategory.NORMAL, NodeType.NORMAL, '\\n\\t</Scripts>');
				node.x = xOffset; node.y = yOffset;
				newGraph.addChild(node);
				newGraph.createArrow(prev, node);
			}
						
			yOffset +=40;
							
			prev = node;
			node = new Node(NodeCategory.NORMAL, NodeType.TERMINAL, '\\n\\t</Object>');
			node.x = xOffset; node.y = yOffset;
			newGraph.addChild(node);
			newGraph.createArrow(prev, node);
			
			graphs.push(newGraph);					
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
			var node:Node = new Node(NodeCategory.NORMAL, NodeType.INITIAL, '\\n<Databases>');
			node.x = xOffset; node.y = yOffset;
			newGraph.addChild(node);
			
			if(XMLList(appXML.Databases).length()>0)
				var dbs:XML = appXML.Databases[0];			 
			
			if(dbs)
			{			
				var i:int = 1;
				for each(var objDb:XML in dbs.elements('Database'))
				{
					var ID:String = Utils.getStringOrDefault(objDb.@ID, UIDUtil.createUID());
					var name:String = Utils.getStringOrDefault(objDb.@Name, '');
					var type:String = Utils.getStringOrDefault(objDb.@Type, '');
					
					yOffset += 40;
					
					prev = node;
					node = new Node(NodeCategory.COMMAND, NodeType.NORMAL, 
						StringUtil.substitute('[sub Database_{0} "{1}" "{2}" "{3}"]',
							i, 
							type,
							ID,
							name));
					node.x = xOffset; node.y = yOffset;
					newGraph.addChild(node);
					newGraph.createArrow(prev, node);
					
					var dbGraph:GraphCanvas = new GraphCanvas();
					dbGraph.category = 'databases';
					dbGraph.name = 'Database_'+i;
				
					var xxOffset:Number = 10;
					var yyOffset:Number = 10;
				
					var _prev:Node;
					var _node:Node = new Node(NodeCategory.NORMAL, NodeType.INITIAL, 
						'\\n\\t<Database Type="$param1" ID="$param2" Name="$param3"><![CDATA[\\-');
					_node.x = xxOffset; _node.y = yyOffset;
					dbGraph.addChild(_node);					
			
					yyOffset +=40;
							
					_prev = _node;
					_node = new Node(NodeCategory.RESOURCE, NodeType.NORMAL, ID);
					_node.x = xxOffset; _node.y = yyOffset;
					dbGraph.addChild(_node);
					dbGraph.createArrow(_prev, _node);
					
					CashManager.setStringObject(
									template.fullID, 
									XML("<resource " + 
											"category='database' " + 
											"ID='"+ID+"' " + 
											"name='"+name+"' " + 
											"type='"+type+"' />"),
									String(objDb));
									
					yyOffset +=40;
									
					_prev = _node;
					_node = new Node(NodeCategory.NORMAL, NodeType.TERMINAL, '\\-]]></Database>');
					_node.x = xxOffset; _node.y = yyOffset;
					dbGraph.addChild(_node);
					dbGraph.createArrow(_prev, _node);
			
					arr.push(dbGraph);
								
					i++;
				}			
			}
			
			yOffset +=40;
							
			prev = node;
			node = new Node(NodeCategory.NORMAL, NodeType.TERMINAL, '\\n</Databases>');
			node.x = xOffset; node.y = yOffset;
			newGraph.addChild(node);
			newGraph.createArrow(prev, node);
									
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
			var node:Node = new Node(NodeCategory.NORMAL, NodeType.INITIAL, '\\n<Resources>');
			node.x = xOffset; node.y = yOffset;
			newGraph.addChild(node);
			
			if(XMLList(appXML.Resources).length()>0)
				var ress:XML = appXML.Resources[0];			 
			
			if(ress)
			{			
				var i:int = 1;
				for each(var objRes:XML in ress.elements('Resource'))
				{

					var ID:String = Utils.getStringOrDefault(objRes.@ID, UIDUtil.createUID());
					var name:String = Utils.getStringOrDefault(objRes.@Name, '');
					var type:String = Utils.getStringOrDefault(objRes.@Type, '');
										
					yOffset += 40;
					
					prev = node;
					node = new Node(NodeCategory.COMMAND, NodeType.NORMAL, 
						StringUtil.substitute('[sub Resource_{0} "{1}" "{2}" "{3}"]',
							i, 
							type,
							ID,
							name));
					node.x = xOffset; node.y = yOffset;
					newGraph.addChild(node);
					newGraph.createArrow(prev, node);
					
					var resGraph:GraphCanvas = new GraphCanvas();
					resGraph.category = 'resources';
					resGraph.name = 'Resource_'+i;
				
					var xxOffset:Number = 10;
					var yyOffset:Number = 10;
				
					var _prev:Node;
					var _node:Node = new Node(NodeCategory.NORMAL, NodeType.INITIAL, 
						'\\n\\t<Resource Type="$param1" ID="$param2" Name="$param3"><![CDATA[\\-');
					_node.x = xxOffset; _node.y = yyOffset;
					resGraph.addChild(_node);					
			
					yyOffset +=40;
							
					_prev = _node;
					_node = new Node(NodeCategory.RESOURCE, NodeType.NORMAL, ID);
					_node.x = xxOffset; _node.y = yyOffset;
					resGraph.addChild(_node);
					resGraph.createArrow(_prev, _node);

					CashManager.setStringObject(
									template.fullID, 
									XML("<resource " + 
											"category='image' " + 
											"ID='"+ID+"' " + 
											"name='"+name+"' " + 
											"type='"+type+"' />"),
									String(objRes));
																		
					yyOffset +=40;
									
					_prev = _node;
					_node = new Node(NodeCategory.NORMAL, NodeType.TERMINAL, '\\-]]></Resource>');
					_node.x = xxOffset; _node.y = yyOffset;
					resGraph.addChild(_node);
					resGraph.createArrow(_prev, _node);
			
					arr.push(resGraph);
								
					i++;
				}			
			}
			
			yOffset +=40;
							
			prev = node;
			node = new Node(NodeCategory.NORMAL, NodeType.TERMINAL, '\\n</Resources>');
			node.x = xOffset; node.y = yOffset;
			newGraph.addChild(node);
			newGraph.createArrow(prev, node);
									
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
			var node:Node = new Node(NodeCategory.NORMAL, NodeType.INITIAL, '\\n<!-- E2vdom -->');
			node.x = xOffset; node.y = yOffset;			
			newGraph.addChild(node);
			
			arr.push(newGraph);
						
			return arr;
		}
					
	}
}