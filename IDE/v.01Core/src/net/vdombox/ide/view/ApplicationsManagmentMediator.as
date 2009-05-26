package net.vdombox.ide.view
{
	import flash.events.Event;
	
	import mx.collections.ArrayCollection;
	import mx.collections.Sort;
	import mx.collections.SortField;
	import mx.events.ListEvent;
	
	import net.vdombox.ide.events.ApplicationItemRendererEvent;
	import net.vdombox.ide.interfaces.IResource;
	import net.vdombox.ide.model.ApplicationProxy;
	import net.vdombox.ide.model.LocaleProxy;
	import net.vdombox.ide.model.ResourceProxy;
	import net.vdombox.ide.model.ServerProxy;
	import net.vdombox.ide.model.vo.ApplicationVO;
	import net.vdombox.ide.view.components.ApplicationsList;
	import net.vdombox.ide.view.components.ApplicationsManagment;
	import net.vdombox.ide.view.controls.ApplicationItemRenderer;
	
	import org.puremvc.as3.multicore.interfaces.IMediator;
	import org.puremvc.as3.multicore.patterns.mediator.Mediator;

	public class ApplicationsManagmentMediator extends Mediator implements IMediator
	{
		public static const NAME : String = "ApplicationManagmentMediator";

		public function ApplicationsManagmentMediator( viewComponent : Object = null )
		{
			super( NAME, viewComponent );
		}

		private var localeProxy : LocaleProxy;
		private var serverProxy : ServerProxy;
		private var resourceProxy : ResourceProxy;
		private var applicationProxy : ApplicationProxy;


		private var applicationItemRenderers : Object = {};

		private function get applicationsManagment() : ApplicationsManagment
		{
			return viewComponent as ApplicationsManagment;
		}

		override public function onRegister() : void
		{
			localeProxy = facade.retrieveProxy( LocaleProxy.NAME ) as LocaleProxy;
			serverProxy = facade.retrieveProxy( ServerProxy.NAME ) as ServerProxy;
			resourceProxy = facade.retrieveProxy( ResourceProxy.NAME ) as ResourceProxy;

			var applicationsList : ApplicationsList = applicationsManagment.applicationsList;

			var applications : ArrayCollection = new ArrayCollection( serverProxy.applications );
			var sort : Sort = new Sort();
			sort.fields = [ new SortField( "name" ) ];
			applications.sort = sort;
			applications.refresh();
			
			applicationsList.dataProvider = applications;
			
			applications.addItem( new ApplicationVO( <xml /> ) );
		}

		private function applicationItemRenderer_iconChanged( event : ApplicationItemRendererEvent ) : void
		{
			if ( !applicationItemRenderers.hasOwnProperty( [ event.iconID ] ) )
				applicationItemRenderers[ event.iconID ] = [];

			applicationItemRenderers[ event.iconID ].push( event.target );

			var resource : IResource = resourceProxy.getResource( "", event.iconID );
			resource.addEventListener( "resource loaded", resourceLoadedHander );

			resource.load();
		}

		private function resourceLoadedHander( event : Event ) : void
		{
			event.target.removeEventListener( "resource loaded", resourceLoadedHander );
			if ( applicationItemRenderers[ event.target.resourceID ] )
			{
				for each ( var item : ApplicationItemRenderer in applicationItemRenderers[ event.target.resourceID ] )
				{
					item.applicationIcon.source = event.target.data;
				}
				delete applicationItemRenderers[ event.target.resourceID ];
			}
		}

		private function applicationList_changeHandler( event : ListEvent ) : void
		{
			var itemRenderer : ApplicationItemRenderer = event.itemRenderer as ApplicationItemRenderer;
			var applicationVO : ApplicationVO = itemRenderer.data as ApplicationVO;

			serverProxy.selectedApplication = applicationVO;
		}
	}
}