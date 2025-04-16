package org.traccar.schedule;

import org.traccar.session.ConnectionManager;

import jakarta.inject.Inject;
import java.util.concurrent.ScheduledExecutorService;
import java.util.concurrent.TimeUnit;

public class TaskWebSocketPeriodicUpdate implements ScheduleTask {

  private static final long PERIOD_SECONDS = 10; // Send updates every 30 seconds

  private final ConnectionManager connectionManager;

  @Inject
  public TaskWebSocketPeriodicUpdate(ConnectionManager connectionManager) {
    this.connectionManager = connectionManager;
  }

  @Override
  public void schedule(ScheduledExecutorService executor) {
    executor.scheduleAtFixedRate(this, PERIOD_SECONDS, PERIOD_SECONDS, TimeUnit.SECONDS);
  }

  @Override
  public void run() {
    connectionManager.sendPeriodicUpdate();
  }
}
