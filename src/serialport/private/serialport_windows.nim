## Windows implementation of serial port handling.

proc openSerialPort*(name: string, baudRate: BaudRate = BaudRate.BR9600,
    dataBits: DataBits = DataBits.eight, parity: Parity = Parity.none,
    stopBits: StopBits = StopBits.one, useHardwareFlowControl: bool = false,
    useSoftwareFlowControl: bool = false): SerialPort {.raises: [InvalidPortNameError, OSError].} =
  ## Open the serial port with the given name.
  ##
  ## If the serial port at the given path is not found, a `InvalidPortNameError` will be raised.
  let portName: string
  if len(name) == 4 and name[3] in {'0'..'9'}:
    portName = name
  else:
    portName = r"\\\\.\\" & name

  let h = createFileW(portName, GENERIC_READ or GENERIC_WRITE,
    0, nil, OPEN_EXISTING, 0, nil)

  if h == INVALID_HANDLE_VALUE:
    raiseOSError(osLastError())

  result = SerialPort(
    name: name,
    handle: h
  )

proc isClosed*(port: SerialPort): bool = discard
  ## Determine whether the given port is open or closed.

proc close*(port: SerialPort) {.raises: [OSError].} = discard
  ## Close the seial port, restoring its original settings.

proc `baudRate=`*(port: SerialPort, br: BaudRate) {.raises: [PortClosedError, OSError].} = discard
  ## Set the baud rate that the serial port operates at.

proc baudRate*(port: SerialPort): BaudRate {.raises: [PortClosedError, OSError].} = discard
  ## Get the baud rate that the serial port is currently operating at.

proc `dataBits=`*(port: SerialPort, db: DataBits) {.raises: [PortClosedError, OSError].} = discard
  ## Set the number of data bits that the serial port operates with.

proc dataBits*(port: SerialPort): DataBits {.raises: [PortClosedError, OSError].} = discard
  ## Get the number of data bits that the serial port operates with.

proc `parity=`*(port: SerialPort, parity: Parity) {.raises: [PortClosedError, OSError].} = discard
  ## Set the parity that the serial port operates with.

proc parity*(port: SerialPort): Parity {.raises: [PortClosedError, OSError].} = discard
  ## Get the parity that the serial port operates with.

proc `stopBits=`*(port: SerialPort, sb: StopBits) {.raises: [PortClosedError, OSError].} = discard
  ## Set the number of stop bits that the serial port operates with.

proc stopBits*(port: SerialPort): StopBits {.raises: [PortClosedError, OSError].} = discard
  ## Get the number of stop bits that the serial port operates with.

proc `hardwareFlowControl=`*(port: SerialPort, enabled: bool) {.raises: [PortClosedError, OSError].} = discard
  ## Set whether to use RTS and CTS flow control for sending/receiving data with the serial port.

proc hardwareFlowControl*(port: SerialPort): bool {.raises: [PortClosedError, OSError].} = discard
  ## Get whether RTS/CTS is enabled for the serial port.

proc `softwareFlowControl=`*(port: SerialPort, enabled: bool) {.raises: [PortClosedError, OSError].} = discard
  ## Set whether to use XON/XOFF software flow control for sending/receiving data with the serial port.

proc softwareFlowControl*(port: SerialPort): bool {.raises: [PortClosedError, OSError].} = discard
  ## Get whether XON?XOFF software flow control is enabled for the serial port.

proc write*(port: SerialPort, data: cstring) {.raises: [PortClosedError, OSError], tags: [WriteIOEffect].} = discard
  ## Write `data` to the serial port. This ensures that all of `data` is written.

proc write*(port: SerialPort, data: string) {.raises: [PortClosedError, OSError], tags: WriteIOEffect.} = discard
  ## Write `data` to the serial port. This ensures that all of `data` is written.

proc read*(port: SerialPort, data: pointer, size: int, timeout: int = -1): int
  {.raises: [PortClosedError, PortReadTimeoutError, OSError], tags: [ReadIOEffect].} = discard
  ## Read from the serial port into the buffer pointed to by `data`, with buffer length `size`.
  ##
  ## This will return the number of bytes received, as it does not guarantee that the buffer will be filled completely.
  ##
  ## The read will time out after `timeout` seconds if no data is received in that time.
  ## To disable timeouts, pass `-1` a the timeout parameter. When timeouts are disabled, this will block until at least 1 byte of data is received.
