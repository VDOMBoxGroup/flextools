package net.vdombox.ide.modules.dataBase.view.components.Queue
{
	import flash.events.EventDispatcher;

	import net.vdombox.ide.modules.dataBase.events.QueueEvent;

	public class QueueManager extends EventDispatcher
	{
		private var externalManager : *;

		private var queue : Array = [];

		private var currentRequestInQueue : int = 0;

		private var inProgress : Boolean = false;

		public function QueueManager( externalManager : * )
		{
			//TODO: implement function
			super( null );

			this.externalManager = externalManager;
		}

		public function get length() : int
		{
			return queue.length;
		}

		public function addRequest(
			GUID : String, methodName : String,
			methodParams : String = '', /* XML String */
			functionOnSuccess : Function = null, functionOnFault : Function = null ) : void
		{

			var request : Object = new Object;

			request[ 'GUID' ] = String( GUID );
			request[ 'method' ] = String( methodName );
			request[ 'params' ] = String( methodParams );
			request[ 'functionOnSuccess' ] = functionOnSuccess;
			request[ 'functionOnFault' ] = functionOnFault;

			queue.push( request );
		}

		public function updateRequest(
			GUID : String, methodName : String,
			methodParams : String = '', /* XML String */
			functionOnSuccess : Function = null, functionOnFault : Function = null ) : void
		{

			/* Search for record in Array */
			var i : int = 0;

			while ( i < queue.length && queue[ i ][ 'GUID' ] != GUID )
			{
				i++;
			}

			if ( i < queue.length && queue[ i ][ 'GUID' ] == GUID )
			{
				queue[ i ][ 'method' ] = methodName;
				queue[ i ][ 'params' ] = methodParams;
				queue[ i ][ 'functionOnSuccess' ] = functionOnSuccess;
				queue[ i ][ 'functionOnFault' ] = functionOnFault;
			}
		}

		public function removeRequest( GUID : String ) : void
		{
			var newQueue : Array = [];

			var i : int = 0;

			while ( i < queue.length )
			{
				if ( queue[ i ][ 'GUID' ] != GUID )
					newQueue.push( queue[ i ] );
				i++;
			}

			queue = newQueue;
		}

		public function reset() : void
		{
			this.externalManager.removeEventListener( "callComplete", remoteMethodCallStandartMsgHandler );
			this.externalManager.removeEventListener( "callError", remoteMethodCallErrorMsgHandler );
			this.removeEventListener( QueueEvent.SUCCESS_RESPONSE, queueRequestSuccesHandler );

			queue = [];
			currentRequestInQueue = 0;
			inProgress = false;
		}

		public function execute() : void
		{
			if ( inProgress )
				return;

			this.externalManager.addEventListener( "callComplete", remoteMethodCallStandartMsgHandler );
			this.externalManager.addEventListener( "callError", remoteMethodCallErrorMsgHandler );
			this.addEventListener( QueueEvent.SUCCESS_RESPONSE, queueRequestSuccesHandler );

			/* Initialise executing the Queue - execute first request */
			try
			{
				externalManager.remoteMethodCall( queue[ currentRequestInQueue ][ 'method' ], queue[ currentRequestInQueue ][ 'params' ] );
			}
			catch ( err : Error )
			{
				return;
			}

			inProgress = true;
		}

		private function queueRequestSuccesHandler( event : QueueEvent ) : void
		{
			currentRequestInQueue++;

			if ( currentRequestInQueue >= queue.length )
			{
				reset();
				
				dispatchEvent( new QueueEvent( QueueEvent.QUEUE_COMPLETE ) );
				
				inProgress = false;
			}
			else
			{
				try
				{
					externalManager.remoteMethodCall( queue[ currentRequestInQueue ][ 'method' ], queue[ currentRequestInQueue ][ 'params' ] );
				}
				catch ( err : Error )
				{
				}
			}
		}


		// ----- Server Messages processing methods ---------------------------------------------

		private function remoteMethodCallStandartMsgHandler( event : * ) : void
		{
			/*
			There are may be 2 responses from server in this section: response that
			everything is OK and standart error message (something wrong with remote
			method parameters).
			*/

			var xmlResult : XML;

			try
			{
				xmlResult = new XML( event.result );
			}
			catch ( err : Error )
			{
				return;
			}

			switch ( xmlResult.name().toString() )
			{

				case "Result":
					try
					{
						if ( queue[ currentRequestInQueue ][ 'functionOnSuccess' ] )
							queue[ currentRequestInQueue ][ 'functionOnSuccess' ]( xmlResult );
					}
					catch ( err : Error )
					{
					}

					this.dispatchEvent( new QueueEvent( QueueEvent.SUCCESS_RESPONSE, xmlResult ) );
					break;

				case "Error":
					try
					{
						if ( queue[ currentRequestInQueue ][ 'functionOnFault' ] )
							queue[ currentRequestInQueue ][ 'functionOnFault' ]( xmlResult );
					}
					catch ( err : Error )
					{
					}

					this.dispatchEvent( new QueueEvent( QueueEvent.STANDART_ERROR, xmlResult ) );
					truncateAndInterrupt( xmlResult );
					break;
			}
		}

		private function remoteMethodCallErrorMsgHandler( event : * ) : void
		{
			/*
			This function handles responses displaying that method could not be executed
			for some reason(s) (may be privilegies reason or method is absent?).
			*/

			var xmlResult : XML;

			try
			{
				xmlResult = new XML( event.result );
			}
			catch ( err : Error )
			{
				return;
			}

			if ( xmlResult.hasOwnProperty( "name" ) && xmlResult.name().toString() == "Result" )
			{

				try
				{
					this.dispatchEvent( new QueueEvent( QueueEvent.SOAP_EXCEPTION, xmlResult.Error, currentRequestInQueue ) );
					truncateAndInterrupt( xmlResult.Error );
					return;
				}
				catch ( err : Error )
				{
					/* Unknown Soap Exception */
					this.dispatchEvent( new QueueEvent( QueueEvent.SOAP_EXCEPTION, xmlResult ) );
				}
			}
			else
			{

				this.dispatchEvent( new QueueEvent( QueueEvent.UNKNOWN_ERROR, xmlResult, currentRequestInQueue ) );
			}

			truncateAndInterrupt( xmlResult );
		}


		private function truncateAndInterrupt( message : String ) : void
		{
			inProgress = false;
			this.dispatchEvent( new QueueEvent( QueueEvent.QUEUE_INTERRUPT, message, currentRequestInQueue ) );

			/* Truncate queue completed requests */
			var newQueue : Array = [];
			var i : int = currentRequestInQueue;

			while ( i < queue.length )
			{
				newQueue.push( queue[ i ] );
				i++;
			}
			queue = newQueue;
			currentRequestInQueue = 0;
		}
	}
}
