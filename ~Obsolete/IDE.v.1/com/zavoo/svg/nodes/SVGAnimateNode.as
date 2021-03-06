package com.zavoo.svg.nodes
{
	
	import com.zavoo.svg.data.SVGColors;
	
	import flash.events.Event;
	import flash.utils.getTimer;
	
	public class SVGAnimateNode extends SVGNode
	{
		private const REPEAT_INFINITE:int = -1;
		
		private const STATE_BEGIN:int = 0;
		private const STATE_RUN:int = 1;
		private const STATE_END:int = 2;
		
		private var _state:int;
		
		private var _field:String;
		
		private var _fromValString:String;
		private var _toValString:String;
		private var _byValString:String;	
		
		private var _fromVal:Number;
		private var _toVal:Number;	
		private var _valSpan:Number
		
		private var _startTime:int;
		
		private var _begin:int;
		private var _duration:int;
		private var _end:int;
				
		private var _repeat:int;
		
		
		public function SVGAnimateNode(xml:XML):void {
			super(xml);		
		}	
		
		override protected function draw():void {		
						
			this._field = this.getAttribute('attributeName');
						
			this._fromValString = this.getAttribute('from');
			this._toValString = this.getAttribute('to');
			this._byValString = this.getAttribute('by');
						
			var begin:String = this.getAttribute('begin');	
			this._begin = timeToMilliseconds(begin);
					
			var duration:String = this.getAttribute('dur');
			this._duration =  timeToMilliseconds(duration);
			
			var end:String = this.getAttribute('end');
			this._end = this._begin + this._duration;
			if (end) {
				this._end = timeToMilliseconds(end);
			}			
			if (this._end < (this._begin + this._duration)) {
				this._end = this._begin + this._duration;
			}
			
			var repeat:String = this.getAttribute('repeatCount');
			var repeatInt:int;
			
			if (repeat == 'indefinite') {
				repeatInt = REPEAT_INFINITE;
			}
			else {
				repeatInt = SVGColors.cleanNumber(repeat);
			}
			
			this._repeat = repeatInt;
			
			this._state = this.STATE_BEGIN;
			this.addEventListener(Event.ENTER_FRAME, renderTween);
			
		}
		
		private function timeToMilliseconds(value:String):Number {
			return (SVGColors.cleanNumber(value) * 1000);
		}		
		
		private function renderTween(event:Event):void {
			var time:int = getTimer();
			
			var timeElapsed:int = time - this._startTime;
			
			
			if (timeElapsed < this._begin) {
				return;
			}
						
			if (this._state == this.STATE_BEGIN) {		
								
				this._fromVal = (this._fromValString) ? SVGColors.cleanNumber(this._fromValString) : SVGColors.cleanNumber(SVGNode(this.parent).getStyle(this._field));
				this._toVal = (this._byValString) ? this._fromVal + SVGColors.cleanNumber(this._byValString) : this._toVal = SVGColors.cleanNumber(this._toValString);
				this._valSpan = this._toVal - this._fromVal;
				
				this._state = this.STATE_RUN;
			}
			
			var runTime:int = timeElapsed - this._begin;
			var newVal:Number;
				
			if (runTime < this._duration) {
				var factor:Number = runTime / this._duration;
				newVal = this._fromVal + (factor * this._valSpan);
				SVGNode(this.parent).setStyle(this._field, newVal.toString());
				/* trace('Tween: ' + this.parent.toString() + ' - Time: ' + timeElapsed.toString() + ' - Field: ' + this._field 
					+ ' - Delay: ' + this._begin.toString() + ' - Duration: ' + this._duration.toString() + ' End: ' + this._end.toString()
					+ ' - Value: ' + newVal.toString()); */
			}
			else {
				newVal = this._toVal;
				if (this._state == this.STATE_RUN) {
					SVGNode(this.parent).setStyle(this._field, newVal.toString());
					/* trace('Tween: ' + this.parent.toString() + ' - Time: ' + timeElapsed.toString() + ' - Field: ' + this._field 
						+ ' - Delay: ' + this._begin.toString() + ' - Duration: ' + this._duration.toString() + ' End: ' + this._end.toString()
						+ ' - Value: ' + newVal.toString()); */
				}
				this._state = this.STATE_END;
				if (timeElapsed > this._end) {
					if (this._repeat == 0) {
						this.removeEventListener(Event.ENTER_FRAME, renderTween);						
					}
					else {
						if (this._repeat > 0) {
							this._repeat--;
						}
						
						this._startTime += this._end;
						this._state = this.STATE_BEGIN;
					}
				}
			}
			 
		}		
		
	}
}