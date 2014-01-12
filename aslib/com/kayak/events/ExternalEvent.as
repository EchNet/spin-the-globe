package com.kayak.events
{
    import flash.events.Event;
    
    /**
     * Type of ActionScript event intended for transmittal to the external
     * Javascript environment.
     */
    public class ExternalEvent
        extends Event
    {
        /**
         * Special event type that indicates the AS client is ready 
         * to communicate.
         */
        public static const READY:String = "ready";

        /**
         * Constructor.
         */
        public function ExternalEvent (type:String)
        {
            super(type);
        }

        /**
         * Create an object that will serve as the representation of this
         * event when translated into Javascript.
         */
        public function createExternalForm():Object
        {
            return { type: type };
        }

        /**
         * Create a copy of this object.  Required by ActionScript event
         * system.
         */
        override public function clone():Event
        {
            return new ExternalEvent (type);
        }
    }
}
