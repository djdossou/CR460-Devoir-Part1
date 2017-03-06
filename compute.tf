//creation de l'instance jumphost
resource "google_compute_instance" "jumphost" {
  name         = "jumphost"
  machine_type = "f1-micro"
  zone         = "us-east1-b"

  disk {
    image = "debian-cloud/debian-8"
  }

  network_interface {
    subnetwork = "${google_compute_subnetwork.public.name}"
    access_config {

    }
  }
}

//creation de l'instance vault
resource "google_compute_instance" "vault" {
  name         = "vault"
  machine_type = "f1-micro"
  zone         = "us-east1-b"

  disk {
    image = "coreos-cloud/coreos-stable"
  }

  network_interface {
    subnetwork = "${google_compute_subnetwork.public.name}"
    access_config {

    }
  }
}

//creation de l'instance Master
resource "google_compute_instance" "master" {
  name         = "master"
  machine_type = "f1-micro"
  zone         = "us-east1-b"

  disk {
    image = "coreos-cloud/coreos-stable"
  }

  network_interface {
    subnetwork = "${google_compute_subnetwork.workload.name}"
    access_config {

    }
  }
}

//CREATION DU TEMPLATE
resource "google_compute_instance_template" "cr460-modele" {
  name        = "cr460-modele"
  machine_type         = "f1-micro"
  can_ip_forward       = false



  // Create a new boot disk from an image
  disk {
    source_image = "coreos-cloud/coreos-stable"
    auto_delete = true
    boot = true
  }


  network_interface {
    subnetwork = "${google_compute_subnetwork.workload.name}"
  }

}

//Creation de l'instance group manager
resource "google_compute_instance_group_manager" "cr460gm" {
  name        = "cr460gm"

  base_instance_name = "worker"
  instance_template  = "${google_compute_instance_template.cr460-modele.self_link}"
  zone               = "us-east1-b"

}


//Autoscaler
resource "google_compute_autoscaler" "workers" {
  name   = "workers"
  zone   = "us-east1-b"
  target = "${google_compute_instance_group_manager.cr460gm.self_link}"

  autoscaling_policy = {
    max_replicas    = 5
    min_replicas    = 2
    cooldown_period = 60

    cpu_utilization {
      target = 0.5
    }
  }
}


//creation de l'instance etcd1
resource "google_compute_instance" "etcd1" {
  name         = "etcd1"
  machine_type = "f1-micro"
  zone         = "us-east1-b"

  disk {
    image = "coreos-cloud/coreos-stable"
  }

  network_interface {
    subnetwork = "${google_compute_subnetwork.backend.name}"
    access_config {

    }
  }
}


//creation de l'instance etcd2
resource "google_compute_instance" "etcd2" {
  name         = "etcd2"
  machine_type = "f1-micro"
  zone         = "us-east1-b"

  disk {
    image = "coreos-cloud/coreos-stable"
  }

  network_interface {
    subnetwork = "${google_compute_subnetwork.backend.name}"
    access_config {

    }
  }
}


//creation de l'instance etcd3
resource "google_compute_instance" "etcd3" {
  name         = "etcd3"
  machine_type = "f1-micro"
  zone         = "us-east1-b"

  disk {
    image = "coreos-cloud/coreos-stable"
  }

  network_interface {
    subnetwork = "${google_compute_subnetwork.backend.name}"
    access_config {

    }
  }
}
