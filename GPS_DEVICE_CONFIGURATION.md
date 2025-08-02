# GPS Device Configuration Guide

This guide shows how to configure different GPS tracking devices to send data to your Railway-deployed Traccar API.

## 🌐 Connection Details

**Your Traccar Server URL**: `https://your-app-name.up.railway.app`
**Available Ports**: Multiple protocols supported (see table below)

## 📱 Supported Device Protocols

### Currently Enabled Protocols

| Protocol      | Port | Common Devices       | Device Examples          |
| ------------- | ---- | -------------------- | ------------------------ |
| **gps103**    | 5001 | TK102, TK103 series  | TK102, TK103A, TK103B    |
| **tk103**     | 5002 | TK103 variants       | TK103, various clones    |
| **gl200**     | 5004 | Queclink devices     | GL200, GL300, GV200      |
| **t55**       | 5005 | Generic T55 protocol | Many Chinese trackers    |
| **meiligao**  | 5009 | Meiligao devices     | MVT100, MVT340, MVT380   |
| **h02**       | 5013 | H02 protocol devices | Many OBD trackers        |
| **jt600**     | 5014 | JT600 series         | JT600, JT701, JT705      |
| **gt06**      | 5023 | GT06 protocol        | GT06, GT06N, many clones |
| **teltonika** | 5027 | Teltonika devices    | FMB120, FMB640, FM1100   |
| **osmand**    | 5055 | OsmAnd mobile app    | Android/iOS app          |

## 🔧 Device Configuration Examples

### 1. TK103 Series (Port 5001 - gps103 protocol)

**SMS Commands:**

```
admin123456                    (default password)
server#your-app-name.up.railway.app#5001#
apn#your-carrier-apn#
```

**Web Interface Settings:**

- **Server**: `your-app-name.up.railway.app`
- **Port**: `5001`
- **Protocol**: TCP

### 2. GT06 Protocol Devices (Port 5023)

**SMS Commands:**

```
FACTORY#                       (reset to factory)
SERVER,1,your-app-name.up.railway.app,5023,0#
```

### 3. Teltonika Devices (Port 5027)

**Configuration Tool Settings:**

- **Server Address**: `your-app-name.up.railway.app`
- **Server Port**: `5027`
- **Protocol**: TCP
- **Data Sending**: Enabled

### 4. OsmAnd Mobile App (Port 5055)

**In OsmAnd App:**

1. Go to **Plugins** → **Trip Recording**
2. Set **Online Tracking Web Address**:
   ```
   https://your-app-name.up.railway.app:5055/?id={deviceid}&lat={lat}&lon={lon}&timestamp={timestamp}&speed={speed}&bearing={bearing}&altitude={altitude}
   ```

### 5. Queclink GL200 Series (Port 5004)

**AT Commands:**

```
AT+GTBSI=gv200,0,0,0,0,5,30,1,1,your-app-name.up.railway.app,5004,,,,,,,,FFFF$
AT+GTTRI=gv200,1,300,600,30,1,1,your-app-name.up.railway.app,5004,0,FFFF$
```

## 🌟 Adding More Protocols

To add additional GPS device protocols, update the `production.xml` file:

```xml
<!-- Add any of these protocols -->
<entry key='protocol-name.port'>PORT_NUMBER</entry>
```

### Popular Additional Protocols:

```xml
<!-- Additional protocols you can enable -->
<entry key='suntech.port'>5011</entry>        <!-- Suntech devices -->
<entry key='megastek.port'>5024</entry>       <!-- Megastek trackers -->
<entry key='navegil.port'>5025</entry>        <!-- Navegil devices -->
<entry key='wondex.port'>5032</entry>         <!-- Wondex trackers -->
<entry key='castel.port'>5086</entry>         <!-- Castel devices -->
<entry key='watch.port'>5093</entry>          <!-- Smart watches -->
<entry key='arnavi.port'>5100</entry>         <!-- Arnavi devices -->
```

Then update `railway.toml` to expose the new ports:

```toml
[[deploy.exposedPorts]]
port = 5011
protocol = "tcp"
```

## 🔑 Device Registration

### Step 1: Get Device IMEI

- Find the 15-digit IMEI number on your device
- Example: `123456789012345`

### Step 2: Configure Device

- Set server address to your Railway app URL
- Set the appropriate port for your device protocol
- Set reporting interval (recommended: 30-60 seconds)

### Step 3: Test Connection

1. Check your device sends data
2. Verify in Traccar web interface: `https://your-app-name.up.railway.app`
3. Login with default credentials: `admin` / `admin`
4. Look for your device in the devices list

## 📊 Testing Your Setup

### 1. Check Device Status

```bash
# Check if device is connecting
curl https://your-app-name.up.railway.app/api/devices
```

### 2. View Latest Positions

```bash
# Get latest positions
curl https://your-app-name.up.railway.app/api/positions
```

### 3. Monitor Logs

- In Railway dashboard, check the **Logs** tab
- Look for device connection messages
- Verify protocol detection

## 🔧 Troubleshooting

### Device Not Connecting

1. **Check Protocol Match**:

   - Ensure device protocol matches enabled port
   - Try generic protocols like `t55` (port 5005) first

2. **Verify Network Settings**:

   - Confirm device has cellular/internet connection
   - Check APN settings for your carrier

3. **Test with OsmAnd App**:
   - Download OsmAnd app on your phone
   - Configure it to send to port 5055
   - This helps verify server connectivity

### Common Issues

| Issue                | Solution                                         |
| -------------------- | ------------------------------------------------ |
| Device not appearing | Check IMEI configuration, try different protocol |
| No position updates  | Verify GPS signal, check reporting interval      |
| Connection timeouts  | Check network connectivity, try different port   |
| Protocol errors      | Use generic protocols like `t55` or `osmand`     |

## 📱 Recommended Testing Sequence

1. **Start with OsmAnd app** (easiest to test)
2. **Try generic T55 protocol** for unknown devices
3. **Use manufacturer-specific protocols** for better features
4. **Check logs** in Railway dashboard for debugging

## 🎯 Production Tips

- **Use HTTPS**: All connections are automatically encrypted via Railway
- **Set reasonable intervals**: 30-60 seconds for vehicles, 5-10 minutes for assets
- **Monitor data usage**: Frequent updates consume more cellular data
- **Backup device settings**: Save configurations before making changes

## 📞 Support

- **Traccar Documentation**: [traccar.org](https://www.traccar.org)
- **Protocol Details**: [traccar.org/protocols](https://www.traccar.org/protocols/)
- **Device Compatibility**: Check manufacturer specifications

---

**Note**: All device communications are automatically secured with HTTPS/TLS when connecting through Railway. No additional SSL configuration needed on devices.
