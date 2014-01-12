package
{
    import com.kayak.events.CommandEvent;
    import com.kayak.globe.GlobeController;
    import com.kayak.globe.GlobeView;
    import com.kayak.motion.MotionUtil;
    import flash.display.DisplayObject;
    import flash.events.Event;
    import flash.utils.getTimer;

    /**
     * Controller for a "take me to this destination" sort of application.
     */
    public class TravelController extends GlobeController
    {
        // Motion parameters.
        public var maxSpinVelocity:Number = 300;
        public var minSpinVelocity:Number = 20;
        public var spinAcceleration:Number = 120;
        public var spinDeceleration:Number = 80;
        public var tiltVelocity:Number = 10;
        public var minSpinTime:Number = 2500;

        // Motion state.
        private var _state:int = RESTING;
        private var _currentSpinVelocity:Number = 0;
        private var _goalSpinVelocity:Number = 0;
        private var _forward:Boolean = false;
        private var _destination:Object;
        private var _timingStart:int;

        // Motion state constants.
        private static const RESTING:int = 0;
        private static const STARTING:int = 1;
        private static const SPINUP:int = 2;
        private static const TIMING:int = 3;
        private static const SEEKING:int = 4;
        private static const SPINDOWN:int = 5;
        private static const SKIDDING:int = 6;
        private static const STOPPING:int = 7;

        /**
         * Constructor.
         */
        public function TravelController(globe:GlobeView, parent:DisplayObject)
        {
            super(globe, parent);
        }

        /**
         * Start the animation sequence.
         */
        public function startTowardDestination(destination:Object):void
        {
            if (_state == RESTING)
            {
                _state = STARTING;
                _destination = destination;
                _forward = !_forward;
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
            switch (_state)
            {
            case STARTING:
                _state = SPINUP;
                _goalSpinVelocity = maxSpinVelocity * (_forward ? -1 : 1);
                dispatchEvent(new Event(START_MOTION));
                break;

            case SPINUP:
                accelerateGlobe(spinAcceleration, elapsed);
                spinGlobe(elapsed);
                tipGlobe(0, elapsed);

                if (MotionUtil.approximate(_currentSpinVelocity,
                                           _goalSpinVelocity) &&
                    MotionUtil.isZero(globe.cameraLatitude))
                {
                    _state = TIMING;
                    _timingStart = getTimer();
                }
                break;

            case TIMING:
                spinGlobe(elapsed);
                if (getTimer() - _timingStart >= minSpinTime)
                {
                    _state = SEEKING;
                }
                break;

            case SEEKING:
                spinGlobe(elapsed);
                tipGlobe(_destination.latitude, elapsed);

                // When we're just beyond the offset from which a deceleration
                // to zero velocity will bring us to the destination longitude,
                // AND the latitude tilt will be complete within that time,
                // start the deceleration.

                // How long it will take to decelerate:
                var decelTime:Number =
                    Math.abs(_currentSpinVelocity / spinDeceleration);

                // Where we'd end up longitudinally if deceleration starts now:
                var longAfterDecel:Number =
                    globe.cameraLongitude + (decelTime * _currentSpinVelocity / 2);

                // How far left to travel from that point.
                var deltaLongitude:Number = calculateDeltaLongitude(longAfterDecel);

                // How far we can skid in a couple of clicks.
                var fudgeFactor:Number = minSpinVelocity * 0.1;

                var timeToReachLatitude:Number =
                    Math.abs((globe.cameraLatitude - _destination.latitude) / tiltVelocity);

                if (deltaLongitude > 0 &&
                    deltaLongitude < fudgeFactor &&
                    timeToReachLatitude < decelTime)
                {
                    _goalSpinVelocity = minSpinVelocity * (_forward ? -1 : 1);
                    _state = SPINDOWN;
                }
                break;

            case SPINDOWN:
                accelerateGlobe(spinDeceleration, elapsed);
                spinGlobe(elapsed);
                tipGlobe(_destination.latitude, elapsed);

                if (MotionUtil.approximate(_currentSpinVelocity,
                                           _goalSpinVelocity))
                {
                    _state = TIMING;
                    _timingStart = getTimer();
                }
                break;

            case SKIDDING:
                globe.cameraLongitude = approachGoal(globe.cameraLongitude, 
                                                    _destination.longitude,
                                                    minSpinVelocity, elapsed);
                tipGlobe(_destination.latitude, elapsed);
                if (MotionUtil.approximate(globe.cameraLongitude,
                                           _destination.longitude))
                {
                    _currentSpinVelocity = 0;
                    _state = STOPPING;
                }
                break;

            case STOPPING:
                _state = RESTING;
                dispatchEvent(new Event(STOP_MOTION));
                break;
            }
        }

        /**
         * Tip the globe toward the destination.
         */
        private function tipGlobe(destLatitude:Number, elapsed:Number):void
        {
            globe.cameraLatitude = approachGoal(globe.cameraLatitude, 
                                                destLatitude,
                                                tiltVelocity, elapsed);
        }

        /**
         * Accelerate/decelerate.
         */
        private function accelerateGlobe(rate:Number, elapsed:Number):void
        {
            _currentSpinVelocity = approachGoal(_currentSpinVelocity,
                                                _goalSpinVelocity,
                                                rate, elapsed);
        }

        /**
         * Turn the globe at its current velocity.
         */
        private function spinGlobe(elapsed:Number):void
        {
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

        private function calculateDeltaLongitude(sourceLongitude:Number):Number
        {
            var destinationLongitude:Number = _destination.longitude;

            if (!_forward)
            {
                sourceLongitude *= -1;
                destinationLongitude *= -1;
            }

            while (destinationLongitude < sourceLongitude)
            {
                destinationLongitude += 360;
            }

            return destinationLongitude - sourceLongitude;
        }
    }
}
