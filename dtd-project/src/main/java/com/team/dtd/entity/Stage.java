package com.team.dtd.entity;

import com.fasterxml.jackson.annotation.JsonRawValue;
import com.team.dtd.enums.StageType;
import jakarta.persistence.*;
import lombok.*;

@Entity
@Table(name = "stages")
@Getter
@NoArgsConstructor(access = AccessLevel.PROTECTED)
@AllArgsConstructor
@Builder
public class Stage {

    @Id
    private Integer idx;

    @Enumerated(EnumType.STRING)
    @Column(name = "stage_type", nullable = false)
    private StageType stageType;

    @Column(name = "stage_name", nullable = false, length = 100)
    private String stageName;

    @JsonRawValue
    @Column(name = "rewards_json", columnDefinition = "LONGTEXT")
    private String rewardsJson;

    @JsonRawValue
    @Column(name = "map_config_json", columnDefinition = "LONGTEXT")
    private String mapConfigJson;
}