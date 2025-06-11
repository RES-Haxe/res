package;

import utest.Runner;
import utest.ui.Report;

class TestMain {
    public static function main() {
        final runner = new Runner();
        runner.addCase(new TestRes());
        Report.create(runner);
        runner.run();
    }
}