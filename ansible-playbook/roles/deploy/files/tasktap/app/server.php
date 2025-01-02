<?php
ini_set('display_errors', 1);
ini_set('error_reporting', E_ALL & ~E_NOTICE & ~E_WARNING);

// Connect to MySQL
function db()
{
    static $mysqli = null;

    if ($mysqli === null) {
        $mysqli = new mysqli(getenv('DB_HOST'), getenv('DB_USER'), getenv('DB_PASS'), getenv('DB_NAME'));
        if ($mysqli->connect_error) {
            die('Adatbáziskapcsolat sikertelen: ' . $mysqli->connect_errno . ' (' . $mysqli->connect_error . ')');
        }
    }
    return $mysqli;
}

// Handle request
switch ($_REQUEST['op']) {
    case "healthcheck":
    case "init":
        $result = db()->query("CREATE TABLE IF NOT EXISTS item (id INT AUTO_INCREMENT PRIMARY KEY, hostname VARCHAR(255), php_ver VARCHAR(255), r VARCHAR(255), i INT, time TIMESTAMP DEFAULT CURRENT_TIMESTAMP)");
        if ($result === false) {
            echo "Error: " . db()->error;
            http_response_code(500);
        } else {
            echo "OK";
            http_response_code(200);
        }
        break;

    case "add":
        $statement = db()->prepare("INSERT INTO item (hostname, php_ver, r, i) VALUES (?, ?, ?, ?)");
        $statement->bind_param("sssi", gethostname(), phpversion(), $_REQUEST["r"], $_REQUEST["i"]);
        $statement->execute();
        if ($statement->error) {
            echo "Error: " . $statement->error;
        } else {
            echo "OK";
        }
        break;

    case "list":
        $statement = db()->prepare("SELECT * FROM item WHERE r = ? ORDER BY time ASC");
        $statement->bind_param("s", $_REQUEST["r"]);
        $statement->execute();
        $result = $statement->get_result();
        $rows = [];
        while ($row = $result->fetch_assoc()) {
            $rows[] = $row;
        }
        echo json_encode($rows);
        break;

    case "phpver":
        echo phpversion();
        break;

    case "info":
        phpinfo();
        break;

    case "version":
        echo "2024.12.11";
        break;

    default:
        echo "Unknown operation: " . $_REQUEST["op"];
        break;
}
