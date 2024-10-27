<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Home - Web Cloudflare DDNS</title>
    <link rel="stylesheet" href="styles.css">
</head>

<body>
    <div class="container">
        <h1>Welcome to Web Cloudflare DDNS</h1>
        <h2 style="text-align: center;">Please create the DNS record before using the update function!</h2>
        <h2>Your Current Public IP Address is:</h2>
        <div class="ip-address">
            <?php
            $ip = shell_exec('curl -4 -s -X GET https://api.ipify.org --max-time 10');
            echo "<p>" . htmlspecialchars($ip) . "</p>";
            if (empty(trim($ip))) {
                echo "<p>Request error or no network.</p>";
            }
            ?>
        </div>
        <h2>Current Configuration:</h2>
        <div class="config">
            <?php
            $config = shell_exec('cat ./script/.env');
            $config_lines = explode("\n", $config);
            foreach ($config_lines as $line) {
                if (strpos($line, '=') !== false) {
                    list($key, $value) = explode('=', $line, 2);
                    echo "<p>" . htmlspecialchars($key) . ": " . htmlspecialchars(trim($value, '"')) . "</p>";
                }
            }
            ?>
        </div>

        <h2>Update Configuration:</h2>
        <form method="post" action="" class="form">
            <label for="record">Record:</label>
            <input type="text" id="record" name="record"><br>

            <label for="zone_id">Zone ID:</label>
            <input type="text" id="zone_id" name="zone_id"><br>

            <label for="token">Token:</label>
            <input type="text" id="token" name="token"><br>

            <label for="email">Email:</label>
            <input type="text" id="email" name="email"><br>

            <label for="proxy">Proxy:</label>
            <input type="text" id="proxy" name="proxy"><br>

            <label for="ttl">TTL:</label>
            <input type="text" id="ttl" name="ttl"><br>

            <input type="submit" name="submit" value="Update">
        </form>

        <?php
        // Update Configuration
        if ($_SERVER['REQUEST_METHOD'] === 'POST') {
            $record = $_POST['record'];
            $zone_id = $_POST['zone_id'];
            $token = $_POST['token'];
            $email = $_POST['email'];
            $proxy = $_POST['proxy'];
            $ttl = $_POST['ttl'];

            $config = file_get_contents('./script/.env');
            $config_lines = explode("\n", $config);
            $new_config = [];

            foreach ($config_lines as $line) {
                if (strpos($line, '=') !== false) {
                    list($key, $value) = explode('=', $line, 2);
                    $value = trim($value, '"'); 
        
                   
                    switch ($key) {
                        case 'record':
                            if (!empty($record)) {
                                $value = trim($record); 
                            }
                            break;
                        case 'zone_id':
                            if (!empty($zone_id)) {
                                $value = trim($zone_id);
                            }
                            break;
                        case 'token':
                            if (!empty($token)) {
                                $value = trim($token);
                            }
                            break;
                        case 'email':
                            if (!empty($email)) {
                                $value = trim($email);
                            }
                            break;
                        case 'proxy':
                            if (!empty($proxy)) {
                                $value = trim($proxy);
                            }
                            break;
                        case 'ttl':
                            if (!empty($ttl)) {
                                $value = trim($ttl);
                            }
                            break;
                    }
                    
                    $new_config[] = "$key=\"$value\"";
                }
            }

            
            file_put_contents('./script/.env', '');  
            $config_data = implode("\n", $new_config) . "\n";
            file_put_contents('./script/.env', $config_data);

            echo "<meta http-equiv='refresh' content='0'>";
        }
        ?>

        <h2>Your Current Crontab Info:</h2>
        <div class="crontab-info">
            <?php
            $crontablist = shell_exec('crontab -l');
            echo "<p>" . htmlspecialchars($crontablist) . "</p>";
            ?>
        </div>

        <h2>Update Crontab:</h2>
        <h4>1) Note that currently ONLY ONE LINE is supported, adding a new one will rewrite the old one.</h4>
        <h4>2) Update with blank to remove the line.</h4>
        <h4>3) Format: min hour day_of_month month day_of_week</h4>
        <h4>4) For execute every minute, type "* * * * *"</h4>
        <form method="post" action="" class="form">
            <label for="crontab">Crontab Entry:</label>
            <input type="text" id="crontab" name="crontab"><br>

            <input type="submit" name="update_crontab" value="Update Crontab">
        </form>

        <?php
        if (isset($_POST['update_crontab'])) {
            $command = "crontab -r"; 
            shell_exec($command);
            $cron = $_POST['crontab'];
            $command = "(crontab -l ; echo \"$cron /app/script/update-dns.sh\") | crontab -";
            shell_exec($command);
        }
        ?>

        <h2>Force Execute</h2>
        <form method="post" action="" class="form">
            <input type="submit" name="force_execute" value="Execute Update DNS">
        </form>


        <?php
        if (isset($_POST['force_execute'])) {
            $command = '/app/script/update-dns.sh';
            shell_exec($command);
            echo "<p class='success-message'>Force executed: $command</p>";
        }
        ?>


        <h2>Log</h2>
        <div class="log">
            <?php
            $log = shell_exec('cat ./script/update-dns.log');
            echo "<p>" . htmlspecialchars($log) . "</p>";
            ?>
        </div>
    </div>
</body>

</html>