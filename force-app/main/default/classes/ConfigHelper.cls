
/**
 * @file ConfigHelper.cls
 * @brief This class provides helper methods to retrieve configuration data.
 */

/**
 * @class ConfigHelper
 * @brief A helper class to fetch configuration details from custom metadata.
 */

/**
 * @method getBoardId
 * @brief Retrieves the Board ID from the Monday_Board__mdt custom metadata.
 * @return The Board ID as a String.
 */
public class ConfigHelper {
    public static String getBoardId() {
        Monday_Board__mdt config = [SELECT Board__c FROM Monday_Board__mdt LIMIT 1];
        return config.Board__c;
    }
}