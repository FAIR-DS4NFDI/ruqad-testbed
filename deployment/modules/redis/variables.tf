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
  description = "Name for the Redis instance, must be unique for each Redis instances"
}

variable "database-port" {
  default = 6379
}

variable "namespace" {
  description = "kubernetes namespace where the Redis instance is deployed"
}
