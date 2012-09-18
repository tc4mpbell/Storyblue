// ActionScript file

package
{
	
	import mx.collections.*;
	import mx.controls.Alert;
	import mx.controls.Tree;
	import mx.core.Application;
	import mx.core.DragSource;
	import mx.core.FlexGlobals;
	import mx.core.UIComponent;
	import mx.core.mx_internal;
	import mx.events.DragEvent;
	import mx.events.ListEvent;
	import mx.managers.DragManager;
	
	import script.Events;
	

	public class DragDrop
	{
		public static function chapters_DragEnter( event:DragEvent ) :void
		{
			var tree:Tree;
			var ds:DragSource = event.dragSource;
			var dragItem:XML;
			if(ds.hasFormat("items"))
			{
				dragItem = (ds.dataForFormat("items") as Array)[0] as XML;
				if(dragItem!=null && dragItem.@type == "scene")
				{
					tree = Tree(event.currentTarget);
					event.preventDefault();
					tree.showDropFeedback(event);
					DragManager.acceptDragDrop(UIComponent(event.currentTarget));
					DragManager.showFeedback(DragManager.COPY);
				}
			}
			else if(ds.hasFormat("treeItems"))
			{
				event.preventDefault();
				
				
				
				dragItem = (ds.dataForFormat("treeItems") as Array)[0] as XML;
				if(dragItem.@type == "scene")
				{
					tree = Tree(event.currentTarget);
					tree.showDropFeedback(event);
					DragManager.acceptDragDrop(UIComponent(event.currentTarget));
					DragManager.showFeedback(DragManager.MOVE);
				}
				else if(dragItem.@isBranch == "true")
				{
					tree = Tree(event.currentTarget);
					tree.showDropFeedback(event);
					DragManager.acceptDragDrop(UIComponent(event.currentTarget));
					DragManager.showFeedback(DragManager.MOVE);
				}
				else
				{
					DragManager.showFeedback(DragManager.NONE);
					return;
				}
			}
			//only allow scenes to be dropped onto chapters.
		}
		public static function chapters_DragOver( event:DragEvent ) :void
		{
			var tree:Tree = Tree(event.currentTarget);
			
			var dropTarget:Tree = Tree(event.currentTarget);
			var r:int = 0;
			try
			{
				r = dropTarget.calculateDropIndex(event);
			}
			catch(ex:Error){}
			tree.selectedIndex = r;
			
						
			var ds:DragSource = event.dragSource;
			var dragItem:XML;
			if(ds.hasFormat("items"))
			{
				dragItem = (ds.dataForFormat("items") as Array)[0] as XML;
				if(dragItem.attribute("type") == "scene")
				{
					event.preventDefault();
					tree.showDropFeedback(event);
					DragManager.acceptDragDrop(UIComponent(event.currentTarget));
					DragManager.showFeedback(DragManager.MOVE);
				}
			}
			else if(ds.hasFormat("treeItems"))
			{
				//event.preventDefault();
				
				tree.selectedIndex = tree.calculateDropIndex(event);
				var node:XML = tree.selectedItem as XML;
				
				//var node:XML = tree.getChildAt(tree.calculateDropIndex(event)) as XML;
				
				var p:XML;
				if(node.attribute("isBranch") == null)
				{
					p = node;	
				}
				else
					p = node.parent();

				dragItem = (ds.dataForFormat("treeItems") as Array)[0] as XML;
				try
				{
					if(dragItem.@type == "scene" && p.parent()!=null && p.parent().name == "chapter")
					{
						tree.showDropFeedback(event);
						DragManager.acceptDragDrop(UIComponent(event.currentTarget));
						DragManager.showFeedback(DragManager.MOVE);
						
					}	
					else if(dragItem.@isBranch == "true")
					{
						//var tree:Tree = Tree(event.currentTarget);
						tree.showDropFeedback(event);
						DragManager.acceptDragDrop(UIComponent(event.currentTarget));
						DragManager.showFeedback(DragManager.MOVE);
					}
					else
					{
						DragManager.showFeedback(DragManager.NONE);
	                    return;
					}
				}
				catch(ex) {}
			}
			
			
			//DragManager.showFeedback(DragManager.COPY);
		}
		
		//could be a scene or a chapter from myself!
		public static function chapters_DragDrop( event:DragEvent ) :void
		{
			
			var tree:Tree = Tree(event.currentTarget);
			
			var ds:DragSource = event.dragSource;
			var dropTarget:Tree = Tree(event.currentTarget);
			
			var r:int = tree.calculateDropIndex(event);
			tree.selectedIndex = r;
			var node:XML = tree.selectedItem as XML;
			var p:*;
			
			if(node.attribute("isBranch") == true || tree.dataDescriptor.hasChildren(node))
			{
				p = node;
				r = 0;
			}
			else
			{
				p = node.parent();
			}
			
			if(event.dragSource.hasFormat("treeItems"))	//from Tree
			{
				event.preventDefault();
				tree.hideDropFeedback(event);
				
				if((node as XML).name() == "chapter" || node.name() == "chapterScene")
				{
					var items:Array = ds.dataForFormat("treeItems") as Array;
					for(var i:Number=0; i < items.length; i++) 
					{
						var xml:XML = items[i] as XML;
						
						if(xml.@type == "scene")	//scene!
						{
							if(node != xml)
							{
								delete FlexGlobals.topLevelApplication.story.xml.chapters..chapterScene.(@title==xml.@title)[0];
	
								//mx.controls.Alert.show("calc'd: " + dropTarget.calculateDropIndex(event).toString());
								//mx.controls.Alert.show("internal: " + tree.mx_internal::_dropData.index);
								var dropIx:int = tree.mx_internal::_dropData.index;
								
								//have index.
								//if > 0, insert after ix-1
								//p == folder we're in.
								
								var nxt:XML = (FlexGlobals.topLevelApplication.story.xml.chapters.chapter.(@title==p.@title)[0].chapterScene as XMLList)[dropIx] as XML;
								(FlexGlobals.topLevelApplication.story.xml.chapters.chapter.(@title==p.@title)[0] as XML).insertChildBefore(nxt,xml.copy());
								
							}
						}
						else if(xml.@isBranch == "true")	//folder!
						{
							if(node != xml) //not dropping on myself
							{
								//delete old chapter node
								delete FlexGlobals.topLevelApplication.story.xml.chapters..chapter.(@title==xml.@title)[0];
								//get drop index
								var dropIx:int = tree.mx_internal::_dropData.index;
								
								var nxt:XML = FlexGlobals.topLevelApplication.story.xml.chapters.chapter.(@title==p.@title)[dropIx] as XML;
								(FlexGlobals.topLevelApplication.story.xml.chapters[0] as XML).insertChildBefore(nxt,xml.copy());
								
							}
						}
	                }
   				}
   				else
   				{
   					//mx.controls.Alert.show("here111");
   					event.preventDefault();	
   					DragManager.showFeedback(DragManager.NONE);
	     			return;
   				}
			}
			else if(event.dragSource.hasFormat("items")) 	//From List
			{		
				event.preventDefault();
				DragManager.showFeedback(DragManager.NONE);
				var items:Array = ds.dataForFormat("items") as Array;
				
				//mx.controls.Alert.show(node.toXMLString());
				
				
				for(var i:Number = 0; i<items.length; i++)
				{
					//get scene XML
					var n = items[i] as XML;
					var newScene:XML = <chapterScene type="scene" title={n.@title} />
					//(items[i] as XML).copy();
					
					//Delete/append node to make the List not remove it! (HACKY!)			
					//var listNode:XML = mx.core.Application.application.story.cards.card.(@title == newScene.@title)[0] as XML;
					//mx.controls.Alert.show(x1.toXMLString());
					
					//var cards:XML = mx.core.Application.application.story.xml.cards as XML;
					var myCard:XML = FlexGlobals.topLevelApplication.story.xml.cards.card.(@title == newScene.@title)[0];
					var nextSib:XML = myCard.parent().children()[ myCard.childIndex() + 1];
					var prevSib:XML = null;
					
					delete(FlexGlobals.topLevelApplication.story.xml.cards.card.(@title == newScene.@title)[0]);
					//mx.core.Application.application.story.cards.appendChild(n.copy() as XML);
					if(nextSib == null)
					{
						try{
						prevSib = myCard.parent().children()[ myCard.childIndex() - 1];
						}catch(e:Error){}
						
						if(prevSib == null)
						{
							//just append
							FlexGlobals.topLevelApplication.story.xml.cards.appendChild(n.copy() as XML);
						}
						else
							FlexGlobals.topLevelApplication.story.xml.cards.insertChildAfter(prevSib, n.copy());
					}
					else
						FlexGlobals.topLevelApplication.story.xml.cards.insertChildBefore(nextSib, n.copy());
					
					//mx.controls.Alert.show("1: "+ newScene.toXMLString());
					//mx.controls.Alert.show("2: "+ newNode.toXMLString());
	
					//add scene to chapter XML in Story
					var chaps:XMLList = FlexGlobals.topLevelApplication.story.xml.chapters.chapter.(@title == XML(p).@title );
					
					//does this scene already exist in a chapter?
					var matchingScenes:XMLList = FlexGlobals.topLevelApplication.story.xml.chapters..chapterScene.(@title == newScene.@title) as XMLList;
					if(matchingScenes.length() <= 0)
					{
						if(chaps.length() > 0)
						{
							//mx.controls.Alert.show("chaplen>0");
							chaps[0].appendChild(newScene);
							
							FlexGlobals.topLevelApplication.treeChapters.addEventListener(ListEvent.CHANGE, Events.chapterNode_ItemClick);
						}
						else
						{
							//mx.controls.Alert.show("else...");
						}	
					}
					else
					{
						//scene already exist
						mx.controls.Alert.show("You've already added that node to a chapter.");
					}
					
				}
			}

		}
		public static function chapters_DragComplete( event:DragEvent ) :void
		{
			var tree:Tree = Tree(event.currentTarget);
			tree.selectedIndex = -1;
		}
		
		
		
	}
}