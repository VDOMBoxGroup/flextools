/*
 * @Author Dramba Victor
 * 2009
 * 
 * You may use this code any way you like, but please keep this notice in
 * The code is provided "as is" without warranty of any kind.
 */

package ro.victordramba.thread
{
	public interface IThread
	{
		/**
		 * Returns true if more work is to do
		 */
		function runSlice():Boolean;
		
		/**
		 * Gets called if the thread was ended prematurely
		 * do your cleanup here
		 */
		function kill():void;
	}
	
}