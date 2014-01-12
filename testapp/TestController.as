package
{
    import com.kayak.globe.GlobeController;
    import com.kayak.globe.GlobeView;
    import com.kayak.motion.MotionUtil;
    import flash.display.DisplayObject;
    import flash.events.Event;

    /**
     * Globe test application controller.
     */
    public class TestController extends GlobeController
    {
        // Motion state.
        private var _currentSpinVelocity:Number = 0;

        // Motion parameters.
        public var maxSpinVelocity:Number = 180;
        public var spinAcceleration:Number = 180;
        public var spinDeceleration:Number = 120;

        /**
         * The "pause" button.
         */
        public var paused:Boolean = false;

        private var _state:int = RESTING;
        private static const RESTING:int = 0;
        private static const FORWARD:int = 1;
        private static const BACKWARD:int = 2;

        /**
         * Constructor.
         */
        public function TestController(globe:GlobeView, parent:DisplayObject)
        {
            super(globe, parent);
        }

        /**
         * Start the normal animation sequence.
         * @param forward if true, the globe spins toward the east, as 
         *                the earth does; else it spins toward the west
         */
        public function startSpin(forward:Boolean):void
        {
            _state = forward ? FORWARD : BACKWARD;
        }

        /**
         * Stop the globe.  If motion is recommenced, the
         * sequence starts over from the beginning.
         * @param declerate if false, the globe stops immediately
         */
        public function stopSpin(decelerate:Boolean = false):void
        {
            _state = RESTING;

            if (!decelerate)
            {
                _currentSpinVelocity = 0;
            }
        }

        /**
         * Update the state of the globe to show the passage of time.
         *
         * @param elapsed the number of milliseconds that have elapsed since
         *                the last call to this method
         */
        override protected function update(elapsed:Number):void
        {
            if (paused) return;

            var goalSpinVelocity:Number = 0;
            var acceleration:Number = spinDeceleration;

            switch (_state)
            {
            case FORWARD:
                goalSpinVelocity = maxSpinVelocity;
                acceleration = spinAcceleration;
                break;
            case BACKWARD:
                goalSpinVelocity = -maxSpinVelocity;
                acceleration = spinAcceleration;
                break;
            }

            _currentSpinVelocity = approachGoal(_currentSpinVelocity,
                                                goalSpinVelocity,
                                                acceleration,
                                                elapsed);

            // Update angle of rotation based on new velocity.
            globe.cameraLongitude += _currentSpinVelocity * elapsed / 1000;
        }

        /**
         * @param rate   rate of change in units per second
         */
        private function approachGoal(current:Number, goal:Number,
                                      rate:Number, elapsed:Number):Number
        {
            // How much change we get at this rate.
            var delta:Number = rate * elapsed / 1000;

            // Is goal attainable at this rate?
            if (Math.abs(current - goal) <= delta)
            {
                return goal;
            }

            // Update to approach goal.
            return current + (delta * (current < goal ? 1 : -1));
        }
    }
}
