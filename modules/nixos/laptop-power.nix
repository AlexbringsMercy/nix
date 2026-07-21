{ ... }:
{
  zramSwap = {
    enable = true;
    algorithm = "zstd";
    memoryPercent = 50;
    priority = 100;
  };

  services.logind.settings.Login = {
    HandleLidSwitch = "suspend";
    HandleLidSwitchExternalPower = "suspend";
    HandlePowerKey = "suspend";
  };

  powerManagement.enable = true;

  # Apple's firmware waits too long to ramp the fan under Linux, which lets
  # short interactive loads hit the 100 C throttle point. Start ramping before
  # heat soak and reach full speed while boost headroom still exists.
  services.t2fanrd = {
    enable = true;
    config.Fan1 = {
      low_temp = 50;
      high_temp = 75;
      speed_curve = "linear";
      always_full_speed = false;
    };
  };
}
