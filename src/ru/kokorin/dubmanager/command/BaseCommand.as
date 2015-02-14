package ru.kokorin.dubmanager.command {
import mx.logging.ILogger;

import ru.kokorin.util.LogUtil;

public class BaseCommand {
    protected const LOGGER:ILogger = LogUtil.getLogger(this);
}
}
