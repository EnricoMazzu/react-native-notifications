import { NativeModules } from 'react-native';
import type { Spec } from '../NativeRNNotifications';

const runtime = globalThis as typeof globalThis & { __turboModuleProxy?: unknown };
const isTurboModuleEnabled = runtime.__turboModuleProxy != null;
const turboModule = isTurboModuleEnabled ? require('../NativeRNNotifications').default : null;

export default ((turboModule ?? NativeModules.RNBridgeModule) as Spec);
