package com.kayak.events
{
    import flash.events.Event;
    import flash.events.EventDispatcher;
    import flash.events.TimerEvent;
    import flash.external.ExternalInterface;
    import flash.utils.getDefinitionByName;
    import flash.utils.Timer;
    
    /**
     * A wrapper around ExternalInterface that adds queuing for 
     * synchronization.  This is a singleton.
     */
    public class ExternalEventBridge 
        extends EventDispatcher
    {
        /**
         * The name of the function for incoming calls from the Javascript.
         */
        public static const IN_FUNC_NAME:String = "asHandleEvent";
        
        /**
         * The name of the Javascript function we call.
         */
        public static const OUT_FUNC_NAME:String = "jsDispatchEvent";

        /**
         * The minimum interval in milliseconds between dispatch of events
         * out to the Javascript environment.
         */
        public static const DELAY_INTERVAL:int = 50;

        // Event queue.
        private var _queue:Array = [];

        // Singleton instance.
        private static var _instance:ExternalEventBridge;

        /**
         * Get the singleton instance.
         */
        public static function get instance():ExternalEventBridge
        {
            if (_instance == null)
            {
                _instance = new ExternalEventBridge();
            }
            return _instance;
        }
        
        /**
         * Constructor.  Should be private, but AS3 prevents that.
         * Do not call directly - call "get instance" instead.
         */
        public function ExternalEventBridge()
        {
            // The best we can do to enforce singleton-hood:
            if (_instance != null)
            {
                throw new Error ("Do not construct ExternalEventBridge");
            }

            ExternalInterface.addCallback(IN_FUNC_NAME, handleIncomingEvent);

            // Dispatch an external event to let the JS environment
            // know we're ready to receive.
            //
            dispatchExternalEvent(new ExternalEvent(ExternalEvent.READY));
        }
        
        /**
         * Send an event out to the Javascript environment.
         * @param event an event
         */
        public function dispatchExternalEvent(event:Event):void
        {
            var eventObj:Object;

            if (event is ExternalEvent)
            {
                eventObj = ExternalEvent(event).createExternalForm();
            }
            else
            {
                eventObj = { type: event.type };
            }

            if (_queue.length == 0)
            {
                // The queue is becoming non-empty.  Schedule the push.
                var tim:Timer = new Timer (DELAY_INTERVAL);
                tim.addEventListener(TimerEvent.TIMER, handleTimer);
                tim.start();
            }

            _queue.push(eventObj);
        }

        /**
         * Handle a tick of the interval timer.
         */
        private function handleTimer(event:TimerEvent):void
        {
            if (_queue.length > 0)
            {
                // Push the first event in the queue out to Javascript.
                ExternalInterface.call(OUT_FUNC_NAME, _queue.shift());

                // If there are no more events, stop ticking. 
                if (_queue.length == 0)
                {
                    Timer(event.target).stop();
                }
            }
        }

        /**
         * Handle an incoming event.
         * @param eventObj the untyped event object from Javascript
         */
        private function handleIncomingEvent(eventObj:Object):void
        {
            // Must transform untyped object into event.
            var eventClass:Class;

            if (eventObj.className == null)
            {
                eventClass = Event;
            }
            else
            {
                eventClass = getDefinitionByName(eventObj.className) as Class;
            }

            var event:Event = new eventClass (eventObj.type);

            for (var propName:String in eventObj)
            {
                switch (propName)
                {
                case "type":
                case "className":
                    break;
                default:
                    event[propName] = eventObj[propName];
                    break;
                }
            }

            dispatchEvent(event);
        }
    }
}
