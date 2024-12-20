#
#  Copyright (c) 2024 Metaform Systems, Inc.
#
#  This program and the accompanying materials are made available under the
#  terms of the Apache License, Version 2.0 which is available at
#  https://www.apache.org/licenses/LICENSE-2.0
#
#  SPDX-License-Identifier: Apache-2.0
#
#  Contributors:
#       Metaform Systems, Inc. - initial API and implementation
#

variable "instance-name" {
  description = "Unique name for the Kadi instance"
}

variable "namespace" {
  description = "kubernetes namespace where the Kadi instance is deployed"
}

variable "kadi-port" {
  description = "Kadi http port"
  default = 5000
}

variable "sqlalchemy-database-uri" {
  description = "Kadi Backend (Postgres)"
}

variable "redis-uri" {
  description = "Kadi Redis"
}
