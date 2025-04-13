/*
 * Copyright 2024 Anton Tananaev (anton@traccar.org)
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
package org.traccar.handler;

import jakarta.inject.Inject;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.traccar.helper.model.PositionUtil;
import org.traccar.model.Device;
import org.traccar.model.Position;
import org.traccar.session.ConnectionManager;
import org.traccar.session.cache.CacheManager;
import org.traccar.storage.Storage;
import org.traccar.storage.StorageException;
import org.traccar.storage.query.Columns;
import org.traccar.storage.query.Condition;
import org.traccar.storage.query.Request;

public class PostProcessHandler extends BasePositionHandler {

    private static final Logger LOGGER = LoggerFactory.getLogger(PostProcessHandler.class);

    private final CacheManager cacheManager;
    private final Storage storage;
    private final ConnectionManager connectionManager;

    @Inject
    public PostProcessHandler(CacheManager cacheManager, Storage storage, ConnectionManager connectionManager) {
        this.cacheManager = cacheManager;
        this.storage = storage;
        this.connectionManager = connectionManager;
    }

    @Override
    public void onPosition(Position position, Callback callback) {
        try {
            if (PositionUtil.isLatest(cacheManager, position)) {
                LOGGER.info("Processing new position - deviceId: {}, positionId: {}, time: {}",
                        position.getDeviceId(), position.getId(), position.getDeviceTime());

                Device updatedDevice = new Device();
                updatedDevice.setId(position.getDeviceId());
                updatedDevice.setPositionId(position.getId());
                storage.updateObject(updatedDevice, new Request(
                        new Columns.Include("positionId"),
                        new Condition.Equals("id", updatedDevice.getId())));

                cacheManager.updatePosition(position);
                LOGGER.info("Broadcasting position update through WebSocket - deviceId: {}, positionId: {}",
                        position.getDeviceId(), position.getId());
                connectionManager.updatePosition(true, position);
            } else {
                LOGGER.info("Skipping position update - not latest position for device: {}, positionId: {}",
                        position.getDeviceId(), position.getId());
            }
        } catch (StorageException error) {
            LOGGER.warn("Failed to update device", error);
        }
        callback.processed(false);
    }

}
