<?php
if ($_SERVER['REQUEST_METHOD'] == 'POST') {
  if (isset($_FILES['image'])) {
    $errors = [];
    $file_name = $_FILES['image']['name'];
    $file_size = $_FILES['image']['size'];
    $file_tmp = $_FILES['image']['tmp_name'];
    $file_type = $_FILES['image']['type'];
    $file_ext = strtolower(end(explode('.', $_FILES['image']['name'])));

    $extensions = ["jpeg", "jpg", "png"];

    if (in_array($file_ext, $extensions) === false) {
      $errors[] = "Extension not allowed, please choose a JPEG or PNG file.";
    }

    if ($file_size > 2097152) {
      $errors[] = 'File size must be less than 2 MB';
    }

    if (empty($errors)) {
      move_uploaded_file($file_tmp, "images/" . $file_name);
      echo "Success";
    } else {
      print_r($errors);
    }
  }
}
?>
